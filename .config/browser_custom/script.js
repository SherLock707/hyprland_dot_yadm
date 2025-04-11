const container = document.getElementById("container");
const colors = ["#cba6f7", "#f5c2e7", "#f38ba8", "#eba0ac", "#fab387", "#f9e2af", "#a6e3a1", "#94e2d5", "#89dceb", "#74c7ec", "#89b4fa"];

const SQUARES = 800;

const getRandomColor = () => colors[Math.floor(Math.random() * colors.length)];

const setColor = (square) => {
  const color = getRandomColor();
  square.style.background = color;
  square.style.boxShadow = `0 0 2px ${color}, 0 0 10px ${color}`;
};

const removeColor = (square) => {
//   square.style.background = "#11111b";
  square.style.background = "rgba(24, 24, 37, 0.3)";
  square.style.boxShadow = "0 0 2px #000";
};

for (let i = 0; i < SQUARES; i++) {
  const square = document.createElement("div");
  square.classList.add("square");
  square.addEventListener("mouseover", () => setColor(square));
  square.addEventListener("mouseout", () => removeColor(square));
  container.appendChild(square);
}
