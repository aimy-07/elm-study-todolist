port module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import FontAwesome exposing (checkSquare, icon, square)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Todo exposing (Todo)
import Todo.Id exposing (Id)



---- MODEL ----


type AddFormS
    = AddFormOpen Todo
    | Sending
    | AddFormClose


type EditFormS
    = EditFormOpen Todo
    | EditFormClose


type alias Model =
    { todos : List Todo
    , addFormS : AddFormS
    , editFormS : EditFormS
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
      , addFormS = AddFormClose
      , editFormS = EditFormClose
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
            ( { model | addFormS = AddFormOpen Todo.initialTodo }, Cmd.none )

        ChangeAddTodoText text ->
            case model.addFormS of
                AddFormOpen newTodo ->
                    ( { model | addFormS = AddFormOpen { newTodo | text = text } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        AddTodo ->
            case model.addFormS of
                AddFormOpen newTodo ->
                    ( { model | addFormS = Sending }, addTodo newTodo )

                _ ->
                    ( model, Cmd.none )

        AddedTodo newTodo ->
            let
                nextTodos =
                    model.todos ++ [ newTodo ]
            in
            ( { model | todos = nextTodos, addFormS = AddFormClose }, Cmd.none )

        CancelAddTodo ->
            ( { model | addFormS = AddFormClose }, Cmd.none )

        OpenEditTodoForm todo ->
            ( { model | editFormS = EditFormOpen todo }, Cmd.none )

        ChangeEditTodoText text ->
            case model.editFormS of
                EditFormOpen newTodo ->
                    ( { model | editFormS = EditFormOpen { newTodo | text = text } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdateTodoText ->
            case model.editFormS of
                EditFormOpen newTodo ->
                    let
                        nextTodos =
                            List.map (\todo -> Todo.updateText newTodo.id newTodo.text todo) model.todos
                    in
                    ( { model | todos = nextTodos, editFormS = EditFormClose }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CancelUpdateTodoText ->
            ( { model | editFormS = EditFormClose }, Cmd.none )

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
            |> viewIf (model.addFormS == AddFormClose)
        , viewAddTodoForm
            |> viewIf (model.addFormS /= AddFormClose)
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

        viewTodoItem =
            case model.editFormS of
                EditFormOpen todo_ ->
                    if todo.id == todo_.id then
                        viewEditTodoForm todo_.text

                    else
                        viewTodoText todo

                EditFormClose ->
                    viewTodoText todo
    in
    div [ class "todo-wrapper" ]
        [ viewDoneIcon
        , viewTodoItem
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


viewTodoText : Todo -> Html Msg
viewTodoText todo =
    span [ onClick <| OpenEditTodoForm todo, class "todo-text" ] [ text todo.text ]



---- ViewHelper ----


viewIf : Bool -> Html msg -> Html msg
viewIf show element =
    case show of
        True ->
            element

        False ->
            text ""



---- PORTS ----


port addTodo : Todo -> Cmd msg


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
