// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


// Copy to clipboard

window.addEventListener("phx:copy", (event) => {
    let text = "http://localhost:4000/todos/" + event.target.value;
      navigator.clipboard.writeText(text)
})


let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()


let todo_id_input = document.querySelector("#control-codes");
let todo_id = todo_id_input.value;

// let selectedSubtaskId = document.querySelector("#selected_subtask_id").textContent.trim().split(":")[1].trim();
// console.log(selectedSubtaskId + "HELLO")

// document.addEventListener('DOMContentLoaded', function() {
//   // Add event listener to the "Edit" button
//   var editButton = document.querySelector('#messages button');
//   editButton.addEventListener('click', function(event) {
//       // Retrieve the selected subtask ID
//       var selectedSubtaskId = document.querySelector("#selected_subtask_id strong").nextSibling.textContent.trim();

//       // Call the function to join the room with the selected subtask ID
//       joinRoom(selectedSubtaskId);
//   });
// });

document.addEventListener('DOMContentLoaded', function() {
  // Add event listener to the card-region element
  var cardRegion = document.querySelector('.card-region');
  if (cardRegion) {
    cardRegion.addEventListener('click', function(event) {
      // Traverse the DOM hierarchy to find the selected_subtask_id1 element
      var selectedSubtaskIdElement = document.querySelector('.main .todos-edit-area .selected-todo #messages #selected_subtask_id1');
      if (selectedSubtaskIdElement) {
        var subtaskId = selectedSubtaskIdElement.textContent.trim();
        // Call the function to join the room with the selected subtask ID
        joinRoom(subtaskId);
      }
    });
  }
});


function joinRoom(subtaskId) {
  console.log('Edit button clicked with subtask ID:', subtaskId);
  let channelName = "room:" + subtaskId;
  let channel = socket.channel(channelName, {}); 

  let titleInput = document.querySelector("#titleInput");
let statusInput = document.querySelector("#statusInput");
let bodyInput = document.querySelector("#bodyInput");




titleInput.addEventListener("input", event => {
  // Define the delay you want before sending the input value to the server (e.g., 500ms)
  let debounceDelay = 500
  // Execute the function after the debounce delay
  debounce(() => {
    let inputValue = event.target.value
    // Broadcast the input value to the Phoenix channel
    // channel.push("new_message", { body: inputValue })
    channel.push("new_message", {field: "title", value: titleInput.value});
  }, debounceDelay)
})



statusInput.addEventListener("input", event => {
    // Define the delay you want before sending the input value to the server (e.g., 500ms)
    let debounceDelay = 500
    // Execute the function after the debounce delay
    debounce(() => {
      let inputValue = event.target.value
      // Broadcast the input value to the Phoenix channel
      // channel.push("new_message", { body: inputValue })
      channel.push("new_message", {field: "status", value: statusInput.value});
    }, debounceDelay)
  })




bodyInput.addEventListener("input", event => {
    // Define the delay you want before sending the input value to the server (e.g., 500ms)
    let debounceDelay = 100
    // Execute the function after the debounce delay
    debounce(() => {
      let inputValue = event.target.value
      // Broadcast the input value to the Phoenix channel
      // channel.push("new_message", { body: inputValue })
      channel.push("new_message", {field: "body", value: bodyInput.value});
    }, debounceDelay)
  })


channel.on("new_message", payload => {
    // Update the corresponding input field based on the received message
    if (payload.field === "title") {
      titleInput.value = payload.value;
    } else if (payload.field === "status") {
      statusInput.value = payload.value;
    } else if (payload.field === "body") {
      bodyInput.value = payload.value;
    }
  });


  channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp); })
      .receive("error", resp => { console.log("Unable to join", resp); });
}




let debounceTimeout = null

// Define a debounce function
function debounce(func, delay) {
  clearTimeout(debounceTimeout)
  debounceTimeout = setTimeout(func, delay)
}


// Working above

document.addEventListener('DOMContentLoaded', function() {
  // Add event listener to the "Edit" button
  var editButton = document.querySelector('.edit-button');
  editButton.addEventListener('click', function(event) {
    // Enable input fields when the "Edit" button is clicked
    document.getElementById('titleInput').disabled = false;
    document.getElementById('statusInput').disabled = false;
    document.getElementById('bodyInput').disabled = false;
  });
});
