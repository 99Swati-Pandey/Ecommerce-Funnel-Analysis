---01_create_session_funnel_view.

--Base Table
CREATE VIEW session_funnel_base AS
WITH purchase_map AS (
    SELECT 
        s.session_id,
        1 AS purchase
    FROM sessions s
    JOIN orders o 
        ON s.customer_id = o.customer_id
       AND o.order_time >= s.start_time
       AND o.order_time <= DATEADD(hour, 2, s.start_time)
    GROUP BY s.session_id
)

SELECT 
    s.session_id,
    s.customer_id,
    s.start_time,
    s.country,
    s.device,
    s.source,

    MAX(CASE WHEN e.event_type = 'page_view'   THEN 1 ELSE 0 END) AS page_view,
    MAX(CASE WHEN e.event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS cart,
    MAX(CASE WHEN e.event_type = 'checkout'    THEN 1 ELSE 0 END) AS checkout,
    ISNULL(p.purchase, 0) AS purchase

FROM sessions s
LEFT JOIN events e
    ON s.session_id = e.session_id
LEFT JOIN purchase_map p
    ON s.session_id = p.session_id

GROUP BY 
    s.session_id, s.customer_id, s.start_time,
    s.country, s.device, s.source, p.purchase;




    CREATE VIEW session_behavior_base AS
SELECT 
    sfb.session_id,
    sfb.customer_id,
    sfb.cart,
    sfb.checkout,
    sfb.purchase,

    COUNT(*) AS total_events,
    SUM(CASE WHEN e.event_type = 'page_view' THEN 1 ELSE 0 END) AS page_views,
    MIN(e.timestamp) AS first_event_time,
    MAX(e.timestamp) AS last_event_time

FROM session_funnel_base sfb
LEFT JOIN events e
    ON sfb.session_id = e.session_id

GROUP BY 
    sfb.session_id,
    sfb.customer_id,
    sfb.cart,
    sfb.checkout,
    sfb.purchase;