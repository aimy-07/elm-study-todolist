module Todo exposing (Todo, updateDone, updateText)

import Todo.Id exposing (Id)


type alias Todo =
    { id : Id
    , text : String
    , done : Bool
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
