-- So sánh doanh thu tháng này so với tháng trước, doanh thu tháng này tăng/giảm bao nhiêu % so với tháng trước? Sử dụng hàm LAG

With monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(total) AS revenue
    FROM invoice
    GROUP BY 1;
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) as previous_month_revenue,
    (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100 AS revenue_change_percentage
FROM monthly_revenue
ORDER BY month;