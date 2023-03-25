const std = @import("std");
const mysql = @cImport(@cInclude("mysql.h"));
const exit = std.os.exit;
const dbname = "testdb";

pub fn main() anyerror!void {
    std.debug.print("Mysql Client version {s}\n\n", .{mysql.mysql_get_client_info()});

    var con = mysql.mysql_init(null);

    if (con == null) {
        std.debug.print("{s}", .{mysql.mysql_error(con)});
        exit(1);
    }

    if (mysql.mysql_real_connect(con, "127.0.0.1", "root", "root", null, 0, null, 0) == null) {
        finish_with_error(con);
    }

    create_db(con);

    mysql.mysql_close(con);

    con = mysql.mysql_init(null);

    if (mysql.mysql_real_connect(con, "127.0.0.1", "root", "root", dbname, 0, null, 0) == null) {
        finish_with_error(con);
    }

    create_table(con);
    insert_data(con);
    retrieve_data(con);
}

fn retrieve_data(con: *mysql.MYSQL) void {
    if (mysql.mysql_query(con, "SELECT * FROM cars") > 0) {
        finish_with_error(con);
    }

    const result = mysql.mysql_store_result(con);

    if (result == null) {
        finish_with_error(con);
    }

    const num_fields = mysql.mysql_num_fields(result);

    var row = mysql.mysql_fetch_row(result);

    while (row != null) {
        var i: usize = 0;
        while (i < num_fields) : (i += 1) {
            std.debug.print("{s}  ", .{row[i]});
        }
        std.debug.print("\n", .{});

        row = mysql.mysql_fetch_row(result);
    }
}

fn insert_data(con: *mysql.MYSQL) void {
    if (mysql.mysql_query(con, "INSERT INTO cars VALUES(1, 'Audi', 52642)") > 0) {
        finish_with_error(con);
    }

    if (mysql.mysql_query(con, "INSERT INTO cars VALUES(2, 'Mercedes', 57127)") > 0) {
        finish_with_error(con);
    }

    if (mysql.mysql_query(con, "INSERT INTO cars VALUES(3,'Skoda',9000)") > 0) {
        finish_with_error(con);
    }

    if (mysql.mysql_query(con, "INSERT INTO cars VALUES(4,'Volvo',29000)") > 0) {
        finish_with_error(con);
    }
}

fn create_table(con: *mysql.MYSQL) void {
    if (mysql.mysql_query(con, "CREATE TABLE cars(id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255), price INT)") > 0) {
        finish_with_error(con);
    }
}

fn create_db(con: *mysql.MYSQL) void {
    if (mysql.mysql_query(con, "DROP DATABASE IF EXISTS " ++ dbname) > 0) {
        finish_with_error(con);
    }

    if (mysql.mysql_query(con, "CREATE DATABASE IF NOT EXISTS " ++ dbname) > 0) {
        finish_with_error(con);
    }
}

fn finish_with_error(con: *mysql.MYSQL) void {
    std.debug.print("{s}", .{mysql.mysql_error(con)});
    mysql.mysql_close(con);
    exit(1);
}
