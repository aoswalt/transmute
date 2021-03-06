defprotocol Transmutable do
  @type t :: any

  @fallback_to_any Application.get_env(:transmute, :fallback_to_any, false)

  @spec purify(t, options :: Keyword.t()) :: any
  def purify(data, opts \\ [])

  @spec tarnish(t, options :: Keyword.t()) :: any
  def tarnish(data, opts \\ [])
end

defimpl Transmutable, for: Map do
  def purify(map, call_opts \\ []) do
    defaults = Application.get_env(:transmute, :defaults, [])

    to_struct =
      call_opts
      |> Keyword.get(:with)
      |> case do
        nil -> nil
        name -> &struct!(name, &1)
      end

    default_opts =
      Enum.reject(
        [
          map_key: Keyword.get(defaults, :purify_key),
          map_shape: Keyword.get(defaults, :purify_shape, to_struct)
        ],
        fn {_k, v} -> is_nil(v) end
      )

    opts = Enum.concat(call_opts, default_opts)

    Transmute.transform(map, opts)
  end

  def tarnish(map, call_opts \\ []) do
    defaults = Application.get_env(:transmute, :defaults, [])

    default_opts =
      Enum.reject(
        [
          map_key: Keyword.get(defaults, :tarnish_key),
          map_shape: Keyword.get(defaults, :tarnish_shape)
        ],
        fn {_k, v} -> is_nil(v) end
      )

    opts = Enum.concat(call_opts, default_opts)

    Transmute.transform(map, opts)
  end
end

defimpl Transmutable, for: Any do
  defmacro __deriving__(module, _struct, derive_options) do
    key_map = Keyword.get(derive_options, :key_map, %{})
    only = Keyword.get(derive_options, :only)
    except = Keyword.get(derive_options, :except)

    if only && except do
      raise CompileError, message: ":only and :except should not be used together"
    end

    defaults = Application.get_env(:transmute, :defaults, [])

    options = Enum.concat(derive_options, defaults)

    purify_opts =
      [
        map_key: Keyword.get(options, :purify_key),
        map_shape: Keyword.get(options, :purify_shape),
        key_map: Transmute.invert_map(key_map),
        only: only,
        except: except
      ]
      |> Keyword.update!(:key_map, fn
        map when map == %{} -> nil
        map -> Macro.escape(map)
      end)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    tarnish_opts =
      [
        map_key: Keyword.get(options, :tarnish_key),
        map_shape: Keyword.get(options, :tarnish_shape),
        key_map: key_map,
        only: only,
        except: except
      ]
      |> Keyword.update!(:key_map, fn
        map when map == %{} -> nil
        map -> Macro.escape(map)
      end)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    quote do
      defimpl Transmutable, for: unquote(module) do
        Module.put_attribute(__MODULE__, :purify_opts, unquote(purify_opts))
        Module.put_attribute(__MODULE__, :tarnish_opts, unquote(tarnish_opts))

        def purify(map, call_opts \\ []) do
          opts =
            Enum.concat([call_opts, @purify_opts, [map_shape: &struct!(unquote(module), &1)]])

          Transmute.transform(map, opts)
        end

        def tarnish(data, call_opts \\ []) do
          map = Map.from_struct(data)
          opts = Enum.concat(call_opts, @tarnish_opts)

          Transmute.transform(map, opts)
        end
      end
    end
  end

  def purify(data, opts \\ [])

  def purify(%_{} = data, opts) do
    data |> Map.from_struct() |> Transmutable.Map.purify(opts)
  end

  def purify(data, _opts) do
    raise Protocol.UndefinedError,
      protocol: Transmutable,
      value: data,
      description: "fallback_to_any specified but unexpected type"
  end

  def tarnish(data, opts \\ [])

  def tarnish(%_{} = data, opts) do
    data |> Map.from_struct() |> Transmutable.Map.tarnish(opts)
  end

  def tarnish(data, _opts) do
    raise Protocol.UndefinedError,
      protocol: Transmutable,
      value: data,
      description: "fallback_to_any specified but unexpected type"
  end
end
