/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package BDR6.EasyService.Data;

import BDR6.EasyService.DBConn.DBException;


/**
 *
 * @author Joan
 */
public class QueryMaker {
    
    /**
     * 
     * @param items the array of column names to pull
     * @param table the table to pull data from
     * @param conditions null if no conditions, a valid string otherwise
     *                   (can use the conditions() method to generate)
     * @return 
     */
    public static String sqlSelect(String[] columns, String table, String conditions) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT ");
        for (int i = 0; i < columns.length; i++) {
            sb.append("`").append(columns[i]);
            if (i < columns.length - 1) {
                sb.append("`, ");
            } else {
                sb.append(" ");
            }
        }
        sb.append("FROM ").append(table);
        if (conditions != null) {
            sb.append(" WHERE ").append(conditions);
        }
        return sb.toString();
    }
    
    /**
     * 
     * @param tokenList the array of tokens to format
     * @return a formatted string with the condition tokens
     */
    public static String sqlConditions(String[] tokenList) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < tokenList.length; i++) {
            sb.append(tokenList[i]);
        }
        return sb.toString();
    }
    
    /**
     * 
     * @param columns the names of columns to insert into
     * @param values the values to insert into the columns, in the same order
     * @param table the name of the table into which data must be inserted
     * @return the SQL statement for insertion
     * @throws DBException if number of values is different to number of items 
     * (invalid query)
     */
    public static String sqlInsert(String[] columns, String[] values, String table) throws DBException {
        if (columns.length != values.length) {
            throw new DBException("Nombre de valeurs différent du nombre de champs");
        }
        StringBuilder sb = new StringBuilder();
        sb.append("INSERT INTO ").append(table).append(" (");
        for (int i = 0; i < columns.length; i++) {
            sb.append(columns[i]);
            if (i < columns.length - 1) {
                sb.append(", ");
            } else {
                sb.append(")");
            }
        }
        sb.append(" VALUES (");
        for (int i = 0; i < values.length; i++) {
            sb.append(values[i]);
            if (i < values.length - 1) {
                sb.append(", ");
            } else {
                sb.append(")");
            }
        }
        return sb.toString();
    }
    
}
