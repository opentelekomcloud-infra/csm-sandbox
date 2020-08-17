#!/usr/bin/env python3

import psycopg2
import logging
import uuid
import os
import yaml

from contextlib import closing
from argparse import ArgumentParser
from psycopg2 import sql
from psycopg2._psycopg import Error, OperationalError


def _parse_param():
    parser = ArgumentParser(description = 'Get data for connection string')
    parser.add_argument('--source', required = True)
    parser.add_argument('--host', required = True)
    parser.add_argument('--port', required = True)
    parser.add_argument('--database', '-db', required = True)
    parser.add_argument('--username', '-user', required = True)
    parser.add_argument('--password', '-pass', required = True)
    args = parser.parse_args()
    logging.info('Parse args')
    return args


def _create_connection_dict() -> dict:
    """Create connection to database"""
    args = _parse_param()
    db_connect = {
        'host': args.host,
        'port': args.port,
        'user': args.username,
        'password': args.password,
        'database': args.database
    }
    return db_connect


def _execute_sql(sql_query: str) -> list:
    """Execute sql query"""
    connection_dict = _create_connection_dict()
    res = list()
    try:
        with closing(psycopg2.connect(**connection_dict)) as conn:
            try:
                with conn.cursor() as cursor:
                    cursor.execute(sql_query)
                    if cursor.description is not None:
                        res = cursor.fetchall()
                    logging.info('SQL was executed')
            except OperationalError as err:
                logging.error('Exception occured when try to execute SQL', exc_info = True)
            conn.commit()
    except Error as e:
        logging.error('Connection error occured', exc_info = True)
    return res


def create_table(schema_name: str, table_name: str, *columns):
    """Create table in database if it not exists"""
    model_query = sql.SQL(
        "create table if not exists {}.{}(id bigint generated by default as identity primary key,{} text);")
    create_table_query = model_query.format(
                                            sql.Identifier(schema_name),
                                            sql.Identifier(table_name),
                                            sql.SQL(', ').join(map(sql.Identifier, columns))
                                           )
    _execute_sql(create_table_query)
    logging.info('Table was created (if not exists)')


def generate_random_values_and_insert_into_table(schema_name: str, table_name: str, range_start: int, range_stop: int, *columns):

    model_query = sql.SQL("insert into {}.{} select generate_series({},{}) as id, md5(random()::text) AS {};")
    record_query = model_query.format(
                                      sql.Identifier(schema_name),
                                      sql.Identifier(table_name),
                                      sql.Literal(range_start),
                                      sql.Literal(range_stop),
                                      sql.SQL(', ').join(map(sql.Identifier, columns)))
    _execute_sql(record_query)


def _get_database_size(db_name: str) -> int:
    """Get database size, returns bytes"""
    model_query = sql.SQL("select pg_database_size({});")
    get_size_query = model_query.format(sql.Literal(db_name))
    return _execute_sql(get_size_query)[0][0]


def is_database_fulfilled(db_name: str, db_max_size: int) -> bool:
    """Check database size and return false if database size is not enough"""
    return _get_database_size(db_name) >= db_max_size


def _logging_configuration():
    """Basic configuration for logging"""
    return logging.basicConfig(
        filename = 'logs.log',
        filemode = 'w',
        level = logging.DEBUG,
        format='%(levelname)s:%(asctime)s:%(message)s')


def main():
    _logging_configuration()
    args = _parse_param()
    logging.info('Script starts')
    with open(args.datafile) as data_file:
        data = yaml.safe_load(data_file)
        n = data['psycopg']['record_count']
        i = 1
        schema_name = 'public'
        table_name = str(uuid.uuid4())
        while not is_database_fulfilled('entities', data['psycopg']['max_size_in_bytes']):
            create_table(schema_name, table_name, 'content')
            generate_random_values_and_insert_into_table(schema_name, table_name, i + (i - 1) * n, i * n, 'content')
            i = i + 1
    logging.info('Script finished')


if __name__ == '__main__':
    main()
