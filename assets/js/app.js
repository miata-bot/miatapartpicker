// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"
import "../css/card.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import Alpine from 'alpinejs'
import Clipboard from "@ryangjchandler/alpine-clipboard"
import { Socket } from "phoenix"
import topbar from "topbar"
import { LiveSocket } from "phoenix_live_view"

Alpine.plugin(Clipboard)
window.Alpine = Alpine
window.Alpine.start()

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let Hooks = {}
Hooks.PushEvent = {
  mounted() {
    window.pushEventHook = this
  }
}
Hooks.ClipboardHook = {
  mounted() {
    window.clipboardHook = this
  },
  clipboard() {
    console.dir(document.getElementById("token").innerHTML);
    var copyText = document.getElementById("token")

    /* Select the text field */
    copyText.select();
    copyText.setSelectionRange(0, 99999); /* For mobile devices */

    /* Copy the text inside the text field */
    document.execCommand("copy");

    /* Alert the copied text */
    alert("Copied the text: " + copyText.value);
  }
}
let liveSocket = new LiveSocket('/live', Socket, {
  dom: {
    onBeforeElUpdated(from, to){
      if(from._x_dataStack){ 
        window.Alpine.clone(from, to); 
      }
    }
  },
  params: {
    _csrf_token: csrfToken
  },
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

function map(val, minA, maxA, minB, maxB) {
  return minB + ((val - minA) * (maxB - minB)) / (maxA - minA);
}

function Card3D(card, ev) {
  let img = card.querySelector('img');
  let imgRect = card.getBoundingClientRect();
  let width = imgRect.width;
  let height = imgRect.height;
  let mouseX = ev.offsetX;
  let mouseY = ev.offsetY;
  let rotateY = map(mouseX, 0, 180, -25, 25);
  let rotateX = map(mouseY, 0, 250, 25, -25);
  let brightness = map(mouseY, 0, 250, 1.5, 0.5);

  img.style.transform = `rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
  img.style.filter = `brightness(${brightness})`;
}

function adjacent(card, fun) {
  if (card.nextElementSibling) {
    card.nextElementSibling.classList[fun]("card3d-adjacent-1");
    if (card.nextElementSibling.nextElementSibling)
      card.nextElementSibling.nextElementSibling.classList[fun]("card3d-adjacent-2")
  }

  if (card.previousElementSibling) {
    card.previousElementSibling.classList[fun]("card3d-adjacent-1");
    if (card.previousElementSibling.previousElementSibling)
      card.previousElementSibling.previousElementSibling.classList[fun]("card3d-adjacent-2")
  }
}

var cards = document.querySelectorAll('.card3d');

cards.forEach((card) => {
  card.addEventListener('mousemove', (ev) => {
    Card3D(card, ev);
    // card.classList.remove("card3d-highlighted")
    adjacent(card, 'add');
  });

  card.addEventListener('mouseleave', (ev) => {
    let img = card.querySelector('img');

    img.style.transform = 'rotateX(0deg) rotateY(0deg)';
    img.style.filter = 'brightness(1)';
    // card.classList.add("card3d-highlighted")
    adjacent(card, 'remove');
  });
})