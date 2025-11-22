#!/usr/bin/env node
// Simple generator: đọc tất cả *.svg trong inputDir, chuyển thành <symbol> trong sprite.svg
// Usage: node generate-sprite.js ./raw-svgs ./dist/sprite.svg
// NOTE: không dùng thư viện ngoài; cho production cân nhắc dùng svgo để tối ưu.

const fs = require('fs');
const path = require('path');

const [,, inputDir = './raw-svgs', outFile = './dist/sprite.svg'] = process.argv;

if (!fs.existsSync(inputDir)) {
  console.error('Input directory not found:', inputDir);
  process.exit(1);
}
const files = fs.readdirSync(inputDir).filter(f => f.endsWith('.svg'));
if (!files.length) {
  console.error('No .svg files in', inputDir);
  process.exit(1);
}

let symbols = [];
for (const file of files) {
  const raw = fs.readFileSync(path.join(inputDir, file), 'utf8');
  // extract viewBox (fallback to 0 0 24 24)
  const vbMatch = raw.match(/viewBox="([^"]+)"/i);
  const viewBox = vbMatch ? vbMatch[1] : '0 0 24 24';
  // strip outer <svg> tags
  const inner = raw
    .replace(/<\?xml[^>]*>/g, '')
    .replace(/<!DOCTYPE[^>]*>/g, '')
    .replace(/<svg[^>]*>/i, '')
    .replace(/<\/svg>/i, '')
    .trim();
  const name = path.basename(file, '.svg')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
  const title = name.replace(/-/g, ' ');
  symbols.push(`<symbol id="icon-${name}" viewBox="${viewBox}" focusable="false"><title>${title}</title>${inner}</symbol>`);
}

const sprite = `<svg xmlns="http://www.w3.org/2000/svg" style="display:none" aria-hidden="true">\n${symbols.join('\n')}\n</svg>\n`;
fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, sprite, 'utf8');
console.log('Wrote sprite to', outFile);