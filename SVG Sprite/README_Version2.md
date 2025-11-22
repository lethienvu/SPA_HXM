# SVG Sprite — hướng dẫn ngắn

```text
Files included in this example:
- icons/sprite.svg          : sprite chứa <symbol> (mẫu)
- scripts/generate-sprite.js: script Node đơn giản để tạo sprite từ folder raw-svgs
- example/index.html        : ví dụ cách inline hoặc load external sprite
```

Best practices & notes:
- Use currentColor:
  - Trong các SVG dùng stroke="currentColor" hoặc fill="currentColor" để đổi màu bằng CSS (color).
- viewBox:
  - Mỗi <symbol> cần viewBox chính xác để scale đúng.
- Accessibility:
  - Nếu icon chỉ trang trí: <svg aria-hidden="true">...</svg>
  - Nếu icon mang ý nghĩa: <svg role="img" aria-label="..."><use href="#id"></use></svg>
  - Lưu ý: khi dùng external sprite, screen reader behavior với <title> bên trong symbol có không đồng nhất; đặt aria-label trên mỗi sử dụng thường an toàn hơn.
- Inline vs External:
  - Inline sprite (dán nội dung sprite.svg trực tiếp vào <body> hoặc templating) hoạt động ổn định.
  - External sprite (referencing a separate file) tiết kiệm băng thông nhưng cần serve cùng origin & đúng cache headers; một số trình duyệt cũ/edge-case cần xlink:href hoặc fetch+inject approach.
- Caching & delivery:
  - Đặt cache headers tốt (long cache + cache-busting bằng filename hash) — sprite hiếm khi đổi.
  - Gzip brotli compression giúp giảm kích thước.
- Tooling:
  - Sử dụng svgo để tối ưu SVG trước khi tạo sprite.
  - Với frontend build dùng @svgstore or svg-sprite-loader để sinh sprite tự động.

How to use generator:
1. Put source SVG files into ./raw-svgs (file names normalized sẽ thành symbol id icon-{name}).
2. Run: node scripts/generate-sprite.js ./raw-svgs ./dist/sprite.svg
3. Serve ./dist/sprite.svg hoặc inline vào HTML.

If you want, I can:
- Tùy biến script để dùng SVGO (minify) hoặc @svgstore.
- Sinh sprite trực tiếp trong build step (Webpack/Rollup/Vite).
- Chuyển từng SVG thành React components nếu bạn cần React.