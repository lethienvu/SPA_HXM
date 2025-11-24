/**
 * PARADISE HR - DUOTONE SVG SPRITE GENERATOR
 * Auto convert all SVG files to duotone style sprite
 */

const fs = require("fs");
const path = require("path");

// Paradise HR Color Palette
const COLORS = {
  primary: "#73c41d",
  primaryDark: "#71c11d",
  secondary: "#004c39",
  secondaryDark: "#004b38",
  accent: "#fbfcfc",
};

// Duotone gradients
const GRADIENTS = `
  <defs>
    <!-- Paradise HR Primary Gradient -->
    <linearGradient id="paradisePrimary" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:${COLORS.primary};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${COLORS.primaryDark};stop-opacity:1" />
    </linearGradient>
    
    <!-- Paradise HR Secondary Gradient -->
    <linearGradient id="paradiseSecondary" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:${COLORS.secondary};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${COLORS.secondaryDark};stop-opacity:1" />
    </linearGradient>
    
    <!-- Paradise HR Duotone -->
    <linearGradient id="paradiseDuotone" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:${COLORS.primary};stop-opacity:0.8" />
      <stop offset="50%" style="stop-color:${COLORS.secondary};stop-opacity:0.6" />
      <stop offset="100%" style="stop-color:${COLORS.primaryDark};stop-opacity:0.9" />
    </linearGradient>
    
    <!-- Light tone for duotone -->
    <linearGradient id="paradiseLight" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:${COLORS.primary};stop-opacity:0.3" />
      <stop offset="100%" style="stop-color:${COLORS.primaryDark};stop-opacity:0.4" />
    </linearGradient>
    
    <!-- Dark tone for duotone -->
    <linearGradient id="paradiseDark" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:${COLORS.secondary};stop-opacity:0.8" />
      <stop offset="100%" style="stop-color:${COLORS.secondaryDark};stop-opacity:0.9" />
    </linearGradient>
  </defs>
`;

// SVG directories to scan
const SVG_DIRS = ["./Full Icon", "./"];

// Output file
const OUTPUT_FILE = "../SPA_VU/assets/paradise-duotone-sprite.svg";

/**
 * Clean and sanitize SVG filename for use as ID
 */
function sanitizeId(filename) {
  return filename
    .replace(/\.svg$/, "")
    .replace(/[^a-zA-Z0-9-_]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "")
    .toLowerCase();
}

/**
 * Convert SVG content to duotone style
 */
function convertToDuotone(svgContent, iconId) {
  // Remove XML declaration and root SVG tags
  let content = svgContent
    .replace(/<\?xml[^>]*>/g, "")
    .replace(/<svg[^>]*>/, "")
    .replace(/<\/svg>$/, "")
    .trim();

  // Convert fills to duotone gradients
  content = content
    // Primary elements (main shapes) -> Dark tone
    .replace(
      /fill="#[^"]*"/g,
      'fill="url(#paradiseDark)" class="duotone-primary"'
    )
    .replace(
      /fill='#[^']*'/g,
      'fill="url(#paradiseDark)" class="duotone-primary"'
    )

    // Stroke elements -> Light tone
    .replace(
      /stroke="#[^"]*"/g,
      'stroke="url(#paradiseLight)" class="duotone-secondary"'
    )
    .replace(
      /stroke='#[^']*'/g,
      'stroke="url(#paradiseLight)" class="duotone-secondary"'
    )

    // Add default fill if none exists
    .replace(
      /<path(?![^>]*fill)/g,
      '<path fill="url(#paradiseDark)" class="duotone-primary"'
    )
    .replace(
      /<circle(?![^>]*fill)/g,
      '<circle fill="url(#paradiseDark)" class="duotone-primary"'
    )
    .replace(
      /<rect(?![^>]*fill)/g,
      '<rect fill="url(#paradiseDark)" class="duotone-primary"'
    )
    .replace(
      /<polygon(?![^>]*fill)/g,
      '<polygon fill="url(#paradiseDark)" class="duotone-primary"'
    )
    .replace(
      /<ellipse(?![^>]*fill)/g,
      '<ellipse fill="url(#paradiseDark)" class="duotone-primary"'
    );

  // Create symbol with standardized viewBox
  return `  <!-- ${iconId} -->
  <symbol id="icon-${iconId}" viewBox="0 0 24 24">
    <g class="duotone-icon">
${content
  .split("\n")
  .map((line) => "      " + line)
  .join("\n")}
    </g>
  </symbol>`;
}

/**
 * Read all SVG files from directories
 */
function readSVGFiles() {
  const svgFiles = [];

  SVG_DIRS.forEach((dir) => {
    if (!fs.existsSync(dir)) return;

    const files = fs.readdirSync(dir);
    files.forEach((file) => {
      if (file.endsWith(".svg") && !file.startsWith(".")) {
        const fullPath = path.join(dir, file);
        const stats = fs.statSync(fullPath);

        if (stats.isFile()) {
          svgFiles.push({
            path: fullPath,
            name: file,
            id: sanitizeId(file),
          });
        }
      }
    });
  });

  return svgFiles;
}

/**
 * Generate duotone sprite
 */
function generateDuotoneSprite() {
  console.log("🎨 Starting Paradise HR Duotone Sprite Generation...\n");

  const svgFiles = readSVGFiles();
  console.log(`📁 Found ${svgFiles.length} SVG files`);

  let spriteContent = `<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
${GRADIENTS}
`;

  let processedCount = 0;
  const errors = [];

  svgFiles.forEach((file) => {
    try {
      const svgContent = fs.readFileSync(file.path, "utf8");
      const symbolContent = convertToDuotone(svgContent, file.id);
      spriteContent += "\n" + symbolContent + "\n";

      processedCount++;
      console.log(`✅ ${file.name} → icon-${file.id}`);
    } catch (error) {
      errors.push(`❌ ${file.name}: ${error.message}`);
      console.log(`❌ ${file.name}: ${error.message}`);
    }
  });

  spriteContent += "\n</svg>";

  // Write output file
  try {
    const outputDir = path.dirname(OUTPUT_FILE);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    fs.writeFileSync(OUTPUT_FILE, spriteContent, "utf8");
    console.log(`\n🎯 SUCCESS! Generated duotone sprite: ${OUTPUT_FILE}`);
    console.log(`📊 Processed: ${processedCount}/${svgFiles.length} icons`);

    if (errors.length > 0) {
      console.log(`\n⚠️  Errors (${errors.length}):`);
      errors.forEach((error) => console.log(error));
    }
  } catch (error) {
    console.error(`❌ Failed to write output file: ${error.message}`);
  }

  // Generate icon list for documentation
  const iconList = svgFiles.map((file) => `"${file.id}"`).sort();
  console.log(`\n📋 Available Icons (${iconList.length}):`);
  console.log(iconList.join(", "));
}

// Run generator
generateDuotoneSprite();
