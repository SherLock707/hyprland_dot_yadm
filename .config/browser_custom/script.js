async function setBorderColorFromSVG(svgUrl) {
  try {
    const response = await fetch(svgUrl);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const svgText = await response.text();
    let extractedColor = null;

    // --- Updated Color Extraction Logic ---

    // 1. Try to find color in <style> tag for .pink-fill
    const styleMatch = svgText.match(/<style[^>]*>([\s\S]*?)<\/style>/); // Find <style> block
    if (styleMatch && styleMatch[1]) {
        const styleContent = styleMatch[1];
        // Look specifically for the fill property within a .pink-fill rule
        const colorMatchInStyle = styleContent.match(/\.pink-fill\s*\{\s*[^}]*fill:\s*([^;\s\}]+)/);
        if (colorMatchInStyle && colorMatchInStyle[1]) {
            extractedColor = colorMatchInStyle[1];
            console.log(`Extracted color from <style> .pink-fill: ${extractedColor}`);
        }
    }

    // 2. Fallback: If not found in style, check direct fill attribute (as before)
    if (!extractedColor) {
        const fillMatch = svgText.match(/fill="([^"]+)"/);
        if (fillMatch && fillMatch[1] && fillMatch[1] !== 'none') {
           extractedColor = fillMatch[1];
           console.log(`Extracted color (direct fill): ${extractedColor}`);
        }
    }

    // 3. Fallback: If still not found, check direct stroke attribute (as before)
    if (!extractedColor) {
       const strokeMatch = svgText.match(/stroke="([^"]+)"/);
       if (strokeMatch && strokeMatch[1] && strokeMatch[1] !== 'none') {
           extractedColor = strokeMatch[1];
           console.log(`Extracted color (direct stroke): ${extractedColor}`);
       }
    }
    // --- End Updated Color Extraction Logic ---

    // Set the CSS variable if a color was found
    if (extractedColor) {
        document.documentElement.style.setProperty('--page-border-color', extractedColor);
        console.log(`Set --page-border-color to: ${extractedColor}`);
    } else {
        // If no color could be extracted by any method, log a warning.
        console.warn(`Could not automatically extract a color from ${svgUrl}. Using default CSS value.`);
    }

  } catch (error) {
    console.error(`Failed to fetch or parse SVG ('${svgUrl}') for border color: ${error}`);
    // The default color defined in CSS will be used in case of error.
  }
}

// --- Call the function (remains the same) ---
setBorderColorFromSVG('neon_cat.svg');

const container = document.getElementById("container");
const colors = ["#cba6f7", "#f5c2e7", "#f38ba8", "#eba0ac", "#fab387", "#f9e2af", "#a6e3a1", "#94e2d5", "#89dceb", "#74c7ec", "#89b4fa"];

const SQUARES = 400;

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