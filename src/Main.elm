port module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import FontAwesome exposing (checkSquare, icon, square)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Todo exposing (Todo)
import Todo.Id exposing (Id)



---- MODEL ----


type FormS
    = Open
    | Sending
    | Close


type alias Model =
    { todos : List Todo
    , addFormS : FormS
    , addingTodo : Todo
    , editFormS : FormS
    , editingTodo : Todo
    }


init : ( Model, Cmd Msg )
init =
    ( { todos =
            [ { id = "xxx1"
              , text = "住みたい街を決める"
              , done = True
              }
            , { id = "xxx2"
              , text = "物件候補を探す"
              , done = False
              }
            , { id = "xxx3"
              , text = "内見の予約を取る"
              , done = False
              }
            ]
      , addFormS = Close
      , addingTodo = Todo.init
      , editFormS = Close
      , editingTodo = Todo.init
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = OpenAddTodoForm
    | ChangeAddTodoText String
    | AddTodo
    | AddedTodo Todo
    | CancelAddTodo
    | OpenEditTodoForm Todo
    | ChangeEditTodoText String
    | UpdateTodoText
    | CancelUpdateTodoText
    | UpdateTodoDone Id


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenAddTodoForm ->
            ( { model | addFormS = Open, addingTodo = Todo.init }, Cmd.none )

        ChangeAddTodoText text ->
            let
                addingTodo =
                    model.addingTodo

                nextAddingTodo =
                    { addingTodo | text = text }
            in
            ( { model | addingTodo = nextAddingTodo }, Cmd.none )

        AddTodo ->
            ( { model | addFormS = Sending }, addTodo { text = model.addingTodo.text } )

        AddedTodo newTodo ->
            let
                nextTodos =
                    model.todos ++ [ newTodo ]
            in
            ( { model | todos = nextTodos, addFormS = Close, addingTodo = Todo.init }, Cmd.none )

        CancelAddTodo ->
            ( { model | addFormS = Close, addingTodo = Todo.init }, Cmd.none )

        OpenEditTodoForm todo ->
            ( { model | editFormS = Open, editingTodo = todo }, Cmd.none )

        ChangeEditTodoText text ->
            let
                editingTodo =
                    model.editingTodo

                nextEditingTodo =
                    { editingTodo | text = text }
            in
            ( { model | editingTodo = nextEditingTodo }, Cmd.none )

        UpdateTodoText ->
            let
                nextTodos =
                    List.map (\todo -> Todo.updateText model.editingTodo.id model.editingTodo.text todo) model.todos
            in
            ( { model | todos = nextTodos, editFormS = Close, editingTodo = Todo.init }, Cmd.none )

        CancelUpdateTodoText ->
            ( { model | editFormS = Close, editingTodo = Todo.init }, Cmd.none )

        UpdateTodoDone id ->
            let
                nextTodos =
                    List.map (\todo -> Todo.updateDone id todo) model.todos
            in
            ( { model | todos = nextTodos }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "TODOリスト" ]
        , div [] <|
            List.map (\todo -> viewTodo todo model) model.todos
        , button [ class "addTodoButton", onClick OpenAddTodoForm ] [ text "TODOを追加する" ]
            |> viewIf (model.addFormS == Close)
        , viewAddTodoForm
            |> viewIf (model.addFormS == Open)
        ]


viewTodo : Todo -> Model -> Html Msg
viewTodo todo model =
    let
        viewDoneIcon =
            case todo.done of
                True ->
                    span [ onClick <| UpdateTodoDone todo.id, class "todo-icon" ] [ icon checkSquare ]

                False ->
                    span [ onClick <| UpdateTodoDone todo.id, class "todo-icon" ] [ icon square ]
    in
    div [ class "todo-wrapper" ]
        [ viewDoneIcon
        , span [ onClick <| OpenEditTodoForm todo, class "todo-text" ] [ text todo.text ]
            |> viewIf (model.editingTodo.id /= todo.id || model.editFormS == Close)
        , viewEditTodoForm model.editingTodo.text
            |> viewIf (model.editingTodo.id == todo.id && model.editFormS == Open)
        ]


viewAddTodoForm : Html Msg
viewAddTodoForm =
    div [ class "addTodoForm-wrapper" ]
        [ input [ class "addTodoForm-input", onInput ChangeAddTodoText ] []
        , button [ class "addTodoForm-saveButton", onClick AddTodo ] [ text "追加する" ]
        , button [ class "addTodoForm-cancelButton", onClick CancelAddTodo ] [ text "やめる" ]
        ]


viewEditTodoForm : String -> Html Msg
viewEditTodoForm inputValue =
    div [ class "editTodoForm-wrapper" ]
        [ input [ class "editTodoForm-input", onInput ChangeEditTodoText, value inputValue ] []
        , button [ class "editTodoForm-saveButton", onClick UpdateTodoText ] [ text "保存する" ]
        , button [ class "editTodoForm-cancelButton", onClick CancelUpdateTodoText ] [ text "やめる" ]
        ]



---- ViewHelper ----


viewIf : Bool -> Html msg -> Html msg
viewIf show element =
    case show of
        True ->
            element

        False ->
            text ""



---- PORTS ----


port addTodo : { text : String } -> Cmd msg


port addedTodo : (Todo -> msg) -> Sub msg



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ addedTodo AddedTodo
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
