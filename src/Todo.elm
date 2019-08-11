module Todo exposing (Todo, updateDone, updateText, init)

import Todo.Id exposing (Id)


type alias Todo =
    { id : Id
    , text : String
    , done : Bool
    }


init : Todo
init =
    { id = ""
    , text = ""
    , done = False
    }


updateText : Id -> String -> Todo -> Todo
updateText id text todo =
    if todo.id == id then
        { todo | text = text }

    else
        todo


updateDone : Id -> Todo -> Todo
updateDone id todo =
    if todo.id == id then
        { todo | done = not todo.done }

    else
        todo
