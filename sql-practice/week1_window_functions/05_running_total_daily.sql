-- Tổng doanh thu dồn theo từng ngày, tính trên bảng invoice.
-- Cách 1: CTE
WITH daily_summary AS (
    SELECT 
        invoice_date::date AS sale_date,
        SUM(total) AS daily_revenue
    FROM invoice
    GROUP BY invoice_date::date
)
SELECT 
    sale_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY sale_date) AS running_total
FROM daily_summary;

-- Cách 2: Lồng aggregation vào trong hàm window
SELECT 
    invoice_date::date AS sale_date,
    SUM(total) AS daily_revenue,
    SUM(SUM(total)) OVER (ORDER BY invoice_date::date) AS running_total
FROM invoice
GROUP BY invoice_date::date
