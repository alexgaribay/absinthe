defmodule Absinthe.Type.Argument do

  @moduledoc """
  Used to define an argument.

  Usually these are defined using the `Absinthe.Type.Definitions.args/1`
  convenience function.
  """

  alias __MODULE__
  alias Absinthe.Type

  use Type.Fetch

  @typedoc """
  Argument configuration

  * `:name` - The name of the argument, usually assigned automatically by
    the `Absinthe.Type.Definitions.args/1` convenience function.
  * `:type` - The type values the argument accepts/will coerce to.
  * `:deprecation` - Deprecation information for an argument, usually
    set-up using the `Absinthe.Type.Definitions.deprecate/1` convenience
    function.
  * `:description` - Description of an argument, useful for introspection.
  """
  @type t :: %{name: binary,
               type: Type.identifier_t,
               default_value: any,
               deprecation: Type.Deprecation.t | nil,
               description: binary | nil,
               __reference__: Type.Reference.t}

  defstruct name: nil, description: nil, type: nil, deprecation: nil, default_value: nil, __reference__: nil

  @doc """
  Build an AST of the args map for inclusion in other types

  ## Examples

  ```
  iex> build_map_ast([foo: [type: :string], bar: [type: :integer]])
  {:%{}, [],
   [foo: {:%, [],
    [{:__aliases__, [alias: false], [:Absinthe, :Type, :Argument]},
     {:%{}, [], [name: "foo", type: :string]}]},
    bar: {:%, [],
   [{:__aliases__, [alias: false], [:Absinthe, :Type, :Argument]},
    {:%{}, [], [name: "bar", type: :integer]}]}]}
  ```
  """
  def build(args) when is_list(args) do
    ast = for {arg_name, arg_attrs} <- args do
      name = arg_name |> Atom.to_string
      arg_data = [name: name] ++ arg_attrs
      arg_ast = quote do: %Absinthe.Type.Argument{unquote_splicing(arg_data |> Absinthe.Type.Deprecation.from_attribute)}
      {arg_name, arg_ast}
    end
    quote do: %{unquote_splicing(ast)}
  end

  defimpl Absinthe.Validation.RequiredInput do

    # Whether the argument is required.
    #
    # * If the argument is deprecated, it is never required
    # * If the argumnet is not deprecated, it is required
    # if its type is non-null
    @doc false
    @spec required?(Argument.t) :: boolean
    def required?(%Argument{type: type, deprecation: nil}) do
      type
      |> Absinthe.Validation.RequiredInput.required?
    end
    def required?(%Argument{}) do
      false
    end

  end

  defimpl Absinthe.Traversal.Node do
    def children(node, _traversal) do
      [node.type]
    end
  end

end
