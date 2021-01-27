/*
 * The MIT License
 * Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
 * Copyright (c) 2019 Estonian Information System Authority (RIA)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

package ee.aktors.misp2.beans;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author arnis.rips
 */
public class MenuActions implements Serializable {

    private static final long serialVersionUID = 1L;
    private int menuItem = 0;
    private String menuAction = "";
    private boolean showAction = true;
    private List<String> actions = new ArrayList<String>();

    /**
     * Initializes variables
     * @param menuItem menuItem to set
     */
    public MenuActions(int menuItem) {
        this.menuItem = menuItem;
    }

    /**
     * Initializes variables
     * @param menuItem menuItem to set
     * @param menuAction menuAction to set
     * @param actions actions to set
     */
    public MenuActions(int menuItem, String menuAction, List<String> actions) {
        this.menuItem = menuItem;
        this.menuAction = menuAction;
        this.actions = actions;
    }
    /**
     * Initializes variables. MenuAction will be first action from actions list
     * @param menuItem menuItem to set
     * @param actions actions to set
     */
    public MenuActions(int menuItem, List<String> actions) {
        this.menuItem = menuItem;
        this.menuAction = actions.get(0);
        this.actions = actions;
    }

    /**
     * Initializes variables. MenuAction will be first action from actions list
     * @param menuItem menuItem to set
     * @param actions actions to set
     * @param showAction true if action menu tab will be displayed
     */
    public MenuActions(int menuItem, List<String> actions, boolean showAction) {
        this(menuItem, actions);
        this.showAction = showAction;
    }

    /**
     * @return actions
     */
    public List<String> getActions() {
        return actions;
    }

    /**
     * @return menuItem
     */
    public int getMenuItem() {
        return menuItem;
    }

    /**
     * @return menuAction
     */
    public String getMenuAction() {
        return menuAction;
    }

    /**
     * @param action action to check for
     * @return true if given action is in actions list, false otherwise
     */
    public boolean contains(String action) {
        if (actions != null) {
            return actions.contains(action);
        }
        return false;
    }

    @Override
    public String toString() {
        return "MenuActions{" + "menuItem=" + menuItem + "menuAction=" + menuAction + "actions=" + actions + "}\n";
    }

    public boolean isShowAction() {
        return showAction;
    }

    public void setShowAction(boolean showAction) {
        this.showAction = showAction;
    }
}
