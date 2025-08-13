create or replace PROCEDURE P_GET_GROSS_MARGIN_PERCENT(P_PROJECT_NAME project.project_name%TYPE)
IS
    v_gross        NUMBER;
    v_project_name VARCHAR2(100) := P_PROJECT_NAME;
    v_sugg_name    VARCHAR2(2000);
BEGIN
    IF v_project_name IS NULL
       OR trim(v_project_name) = '' THEN
        dbms_output.put_line('ERROR: Project name cannot be empty');
        RETURN;
    END IF;
    
    v_gross := get_gross_margin(v_project_name);
    IF v_gross IS NOT NULL THEN
        dbms_output.put_line('GROSS MARGIN : '
                             || v_gross
                             || '%');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Status: Project does not exist in the database.');
        dbms_output.put_line('Action: Please verify the project name and try again!');
        BEGIN
            SELECT
                LISTAGG(project_name||chr(13), '') WITHIN GROUP(
                ORDER BY
                    project_name
                )
            INTO v_sugg_name
            FROM
                (
                   upper(project_name) LIKE '%'
                                             || upper(v_project_name)
                                             || '%'
                );

            dbms_output.put_line('SUGGESTED NAME: ' || v_sugg_name);
            IF v_sugg_name is null
                then raise no_data_found;
            end if;
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('No similar project names found.');
            WHEN OTHERS THEN
                dbms_output.put_line('Unable to suggest alternative names.');
        END;

    WHEN value_error THEN
        dbms_output.put_line('Status: Unable to calculate gross margin due to invalid data.');
        dbms_output.put_line('Action: Check project name format and try again with correct data!');
    WHEN OTHERS THEN
        dbms_output.put_line('Status: An unexpected system error occurred.');
        dbms_output.put_line('Action: Please try again later!');
        dbms_output.put_line('Error Code: '
                             || sqlcode
                             || ' - '
                             || sqlerrm);
END GET_GROSS_MARGIN_PERCENT;