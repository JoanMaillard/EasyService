/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package BDR6.EasyService.DBConn;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import java.util.Calendar;
import java.util.Date;

/**
 *
 * @author Joan
 */
public abstract class DBHandler {
    private static final String MYSQL_HOST = "localhost";
    private static final String MYSQL_PORT = "3306";
    private static final String MYSQL_DATABASE = "EasyService";
    private static String mysql_user;
    private static String mysql_password;
    
    public static void initialize(String user, String password){
        mysql_user = user;
        mysql_password = password;
    }
    
    private DBHandler(){}
    private static Connection dBConnection = null;
    
    public static final String generateCurrentDateString() {
        return generateDateString(Calendar.getInstance().getTime());
    }

    public static final String generateDateString(Date cal) {
        return cal.toString();
    }
    
    public static final Connection getConnection() throws SQLException {
        return DBHandler.getConnection(false);
    }

    public static final Connection getConnection(boolean ensureSchema) throws SQLException {
        if (DBHandler.dBConnection == null || DBHandler.dBConnection.isClosed()) {
            DBHandler.dBConnection = DriverManager.getConnection(
                "jdbc:mysql://" + MYSQL_HOST   +
                ":" + MYSQL_PORT +
                "/" + MYSQL_DATABASE + "?serverTimezone=CET",
                mysql_user,
                mysql_password
            );
        }
        if (ensureSchema && (DBHandler.dBConnection.getSchema() == null || !DBHandler.dBConnection.getSchema().equals(MYSQL_DATABASE))) {
            DBHandler.dBConnection.setSchema(MYSQL_DATABASE);
        }
        return DBHandler.dBConnection;
    }
    
    /**
     * Formats strings to be present in the middle of an SQL query
     * @param stringsToFormat The array of strings to format
     * @return "String1", "String2", "String3" [...]
     */
    public static final String formatStringsForQuery(String[] stringsToFormat) {
        return formatStringForQuery(String.join("\", \"", stringsToFormat));
    }

    public static final String formatStringForQuery(String stringToFormat) {
        StringBuilder sb = new StringBuilder();
        sb.append("\"").append(stringToFormat).append("\"");
        return sb.toString();
    }
}
