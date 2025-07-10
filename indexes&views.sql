--indexes--
--Lists all indexes in the current schema
SELECT 
    index_name, 
    table_name, 
    index_type, 
    uniqueness, 
    status
FROM 
    user_indexes
ORDER BY 
    table_name, index_name;
    

    
--views--
--This query retrieves critical constraint information from our database, specifically focusing on primary keys (P) and unique constraints (U)
SELECT 
    a.constraint_name, 
    a.constraint_type, 
    a.table_name, 
    b.column_name, 
    a.status
FROM 
    user_constraints a
JOIN 
    user_cons_columns b ON a.constraint_name = b.constraint_name
WHERE 
    a.constraint_type IN ('P', 'U')  -- 'P' = Primary Key, 'U' = Unique
ORDER BY 
    a.table_name, a.constraint_name;
    
--List all views in the current schema:
SELECT 
    view_name, 
    text
FROM 
    user_views
ORDER BY 
    view_name;
    
--Get the SQL definition of a specific view
SELECT 
    text 
FROM 
    user_views 
WHERE 
    view_name = 'CUSTOMER_SUMMARY';
    
--List all views with their dependencies
SELECT 
    a.view_name, 
    a.text, 
    b.referenced_name AS referenced_table
FROM 
    user_views a
JOIN 
    user_dependencies b ON a.view_name = b.name
WHERE 
    b.type = 'VIEW' 
    AND b.referenced_type = 'TABLE'
ORDER BY 
    a.view_name;