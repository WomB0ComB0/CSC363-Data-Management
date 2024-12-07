SELECT
  CAMIS AS '_id',
  LOWER(DBA) AS 'dba',
  LOWER(BORO) AS 'boro',
  LOWER(BUILDING) AS 'building',
  LOWER(STREET) AS 'street',
  ZIPCODE,
  PHONE,
  (
    SELECT
      JSON_ARRAYAGG(
        JSON_OBJECT(
          'inspection_date',
          inspection_date,
          'score',
          score,
          'violations',
          (
            SELECT
              JSON_ARRAYAGG(
                JSON_OBJECT(
                  'violation_code',
                  violation_code,
                  'violation_description',
                  LOWER(violation_description)
                )
              )
            FROM
              violations
            WHERE
              violations.inspection_id = inspections.inspection_id
          )
        )
      )
    FROM
      inspections
    WHERE
      inspections.CAMIS = restaurant.CAMIS
  ) AS inspections
FROM
  restaurant;