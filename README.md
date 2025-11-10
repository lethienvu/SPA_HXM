# Mini SPA Framework (HTML/CSS/JS + Bootstrap)

Mô tả ngắn:
- Router client-side (history API + hash fallback)
- Component base class với render, onMount, onUnmount
- Lazy loading components qua dynamic import()
- Ví dụ pages: Home, About, Users, 404
- Bootstrap 5 dùng cho giao diện

Cách chạy:
1. Chạy một local server (VS Code Live Server hoặc `python -m http.server 8000`)
2. Mở http://localhost:8000
3. Dùng menu hoặc các link (data-link) để chuyển trang mà không reload toàn trang.

Mở rộng ý tưởng (gợi ý):
- Thêm route guards, transitions, nested routes
- Hỗ trợ template binding hoặc reactive state để tự động cập nhật view
- Hỗ trợ prefetching cho lazy routes
- Thêm hệ thống plugin, service (API client), i18n

Tôi đã cung cấp code framework và vài component ví dụ. Nếu bạn muốn tôi:
- thêm nested routes hoặc route guard?
- biến router thành single-file bundle (rollup/webpack) để deploy?
- mở rộng hệ thống component với reactive state (mini-reactive)?
hãy nói tính năng bạn muốn tôi thêm, tôi sẽ cập nhật code tương ứng.