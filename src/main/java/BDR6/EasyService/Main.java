/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package BDR6.EasyService;
import BDR6.EasyService.Interface.MainWindow;
import BDR6.EasyService.Applicative.ItemHandler;
import BDR6.EasyService.Applicative.QueryHandler;

/**
 *
 * @author Joan
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    ItemHandler itemHandler = new ItemHandler();
    
    public static void main(String[] args) {
        MainWindow.main(args);
    }
    
}
