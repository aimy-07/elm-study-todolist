import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import uuidv4 from 'uuid/v4';

const app = Elm.Main.init({
  node: document.getElementById('root')
});

registerServiceWorker();

// -----------------------------
// Port
// -----------------------------
app.ports.addTodo.subscribe((newTodo) => {
  const uuid = uuidv4();
  newTodo.id = uuid;
  app.ports.addedTodo.send(newTodo);
});