SELECT 
    t.NAME 'Table name',
    i.NAME 'Index name',
    ips.index_type_desc,
    ips.alloc_unit_type_desc,
    ips.index_depth,
    ips.index_level,
    ips.avg_fragmentation_in_percent,
    ips.fragment_count,
    ips.avg_fragment_size_in_pages,
    ips.page_count,
    ips.avg_page_space_used_in_percent,
    ips.record_count,
    ips.ghost_record_count,
    ips.Version_ghost_record_count,
    ips.min_record_size_in_bytes,
    ips.max_record_size_in_bytes,
    ips.avg_record_size_in_bytes,
    ips.forwarded_record_count
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
INNER JOIN  
    sys.tables t ON ips.OBJECT_ID = t.Object_ID
INNER JOIN  
    sys.indexes i ON ips.index_id = i.index_id AND ips.OBJECT_ID = i.object_id
WHERE
    AVG_FRAGMENTATION_IN_PERCENT > 0.0
ORDER BY
    AVG_FRAGMENTATION_IN_PERCENT, fragment_count