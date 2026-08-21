# Day 8 (18/8): Index Types

| Loại index | Toán tử hỗ trợ | Khi nào dùng |
|---|---|---|
| B-tree (mặc định) | =, <, <=, >, >=, BETWEEN, ORDER BY, LIKE 'prefix%' | Mặc định cho hầu hết cột cần lọc/sắp xếp |
| Hash | chỉ = | Hiếm dùng thực tế, dù nhanh hơn B-tree cho riêng phép so sánh bằng |
| GIN | chứa trong mảng/JSONB, full-text search | Khi cột là JSONB, array, hoặc cần tìm kiếm văn bản |

### Quan sát thực tế (orders_big, 10 triệu dòng)
- `WHERE order_id = 12345` → Index Scan (nhờ PRIMARY KEY tự động có index)
- `WHERE customer_id = 12345` → Seq Scan (chưa có index)