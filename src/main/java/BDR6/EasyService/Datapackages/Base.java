/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package BDR6.EasyService.Datapackages;

import java.sql.ResultSet;
import java.sql.SQLException;

import BDR6.EasyService.DBConn.DBException;
import BDR6.EasyService.DBConn.DBHandler;
import java.sql.Statement;

/**
 *
 * @author Joan
 */
public abstract class Base {
    public final long DBID_NOT_SET = -1;
    protected long DBID = DBID_NOT_SET;
    
    protected void setID(int newID) {
        this.DBID = newID;
    }
    
    abstract String insertSQL();
    
    abstract String updateSQL();
    
    abstract String retrievalSQL(long id);
    
    abstract void mapResultSet(ResultSet res) throws SQLException;
    
    public final void addToDB() throws SQLException, DBException {}
    
    public final void commit() throws SQLException, DBException {}
    
    final void load(long id) throws SQLException {
        this.DBID = id;
        try (Statement p = DBHandler.getConnection().createStatement()) {
            this.mapResultSet(p.executeQuery(this.retrievalSQL(id)));
        }
    }
    
}
