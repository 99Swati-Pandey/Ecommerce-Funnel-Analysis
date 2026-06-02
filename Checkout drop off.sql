--- as Biggest drop(after purchase) is: add_to_cart → checkout (45% drop)


-- Calculate add_to_cart_seesion , checkout_session, cart_to_checkout conversion and dropoff rate

--Country Analysis
SELECT 
    country,

    SUM(cart) AS add_to_cart_sessions,
    SUM(checkout) AS checkout_sessions,

    ROUND(SUM(checkout) * 1.0 / NULLIF(SUM(cart), 0), 3) 
        AS cart_to_checkout_conversion_rate,

    ROUND((SUM(cart) - SUM(checkout)) * 1.0 / NULLIF(SUM(cart), 0), 3) 
        AS cart_to_checkout_dropoff_rate

FROM session_funnel_base
GROUP BY country
ORDER BY cart_to_checkout_dropoff_rate DESC;

 --Result :-Checkout conversion across countries ranges narrowly between
 --         52.5% and 56.5%,indicating no major geographic friction. 
 --          It means Checkout_drop is not country specific.


 -- Checkout Conversion by Device.
SELECT 
    device,

    SUM(cart) AS add_to_cart_sessions,
    SUM(checkout) AS checkout_sessions,

    ROUND(SUM(checkout) * 1.0 / NULLIF(SUM(cart), 0), 3) 
        AS cart_to_checkout_conversion_rate,

    ROUND((SUM(cart) - SUM(checkout)) * 1.0 / NULLIF(SUM(cart), 0), 3) 
        AS cart_to_checkout_dropoff_rate

FROM session_funnel_base
GROUP BY device
ORDER BY cart_to_checkout_dropoff_rate DESC;


 --Result :-Checkout conversion by device ranges narrowly between
 --         54.9% and 55.1%,indicating no major friction across device. 
 --         It means Checkout_drop is not device specific.



 -- Checkout Conversion by Source
SELECT 
    source,

    SUM(cart) AS add_to_cart_sessions,
    SUM(checkout) AS checkout_sessions,

    ROUND(SUM(checkout) * 1.0 / NULLIF(SUM(cart), 0), 3) 
        AS cart_to_checkout_conversion_rate,

    ROUND((SUM(cart) - SUM(checkout)) * 1.0 / NULLIF(SUM(cart), 0), 3) 
        AS cart_to_checkout_dropoff_rate

FROM session_funnel_base
GROUP BY source
ORDER BY cart_to_checkout_dropoff_rate DESC;

 --Result :-Checkout conversion by source ranges between 54.9% and 55.5%, 
 --         indicating no significant variation across traffic sources. 
 --         It means Checkout_drop is not source specific.



 --CHECKOUT CONVERSION by country, device and source (multi-dimensional)
WITH funnel AS ( SELECT s.country,s.source,s.device, 
COUNT(DISTINCT CASE WHEN e.event_type = 'add_to_cart' THEN e.session_id END)
AS add_to_cart_sessions, COUNT(DISTINCT CASE WHEN e.event_type = 'checkout' 
THEN e.session_id END) AS checkout_sessions FROM events e JOIN sessions s ON 
e.session_id = s.session_id GROUP BY s.country, s.source,s.device)
SELECT country,source,device,add_to_cart_sessions,checkout_sessions, 
ROUND(checkout_sessions * 1.0 / NULLIF(add_to_cart_sessions,0), 3) AS cart_to_checkout_conversion_rate,
ROUND((add_to_cart_sessions - checkout_sessions) * 1.0 / NULLIF(add_to_cart_sessions,0), 3) 
AS cart_to_checkout_dropoff_rate FROM 
funnel ORDER BY cart_to_checkout_dropoff_rate DESC;

--- At first glance, the multi-dimensional segmentation showed a wide variation 
---in cart-to-checkout conversion rates, ranging from approximately 30% to 80% 
--across different Country × Source × Device combinations.

--However, deeper investigation revealed that:

--The extreme high and low conversion rates were concentrated in very small sample segments.

--These combinations had low add-to-cart session counts, making their conversion rates statistically unstable.

--After applying a minimum volume threshold to filter out small-sample noise, the conversion rates across high-volume segments consistently clustered around ~54–56%.

--This indicates that the apparent variability was driven by sample size distortion rather than genuine behavioral differences..



--Result :- Multi-dimensional segmentation analysis (Country × Source × Device)
--          reveals consistent checkout conversion (~55%) across high-volume segments, 
--          indicating systemic friction withinthe checkout flow rather than 
--          segment-driven behavioral differences.










