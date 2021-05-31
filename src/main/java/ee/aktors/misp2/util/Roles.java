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

package ee.aktors.misp2.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author arnis.rips
 */
public final class Roles {
    private static final Logger LOGGER = LogManager.getLogger(Roles.class.getName());
    // roles bitmasks
    public static final int NO_RIGHTS = 0;
    public static final int DUMBUSER = 1;
    public static final int PERMISSION_MANAGER = 2;
    public static final int DEVELOPER = 4;
    public static final int PORTAL_MANAGER = 8;
    public static final int PORTAL_ADMIN = 16;
    public static final int REPRESENTATIVE = 32;
    public static final int UNREGISTERED = 64;
    public static final int LIMITED_REPRESENTATIVE = 128;
    private static final int[] ALL_REAL_ROLES =
            new int[] {DUMBUSER, PERMISSION_MANAGER, DEVELOPER, PORTAL_MANAGER, UNREGISTERED};
    // role prefixes
    public static final String ROLE_DUMBUSER = "U";
    public static final String ROLE_PERMISSION_MANAGER = "P";
    public static final String ROLE_DEVELOPER = "A";
    public static final String ROLE_PORTAL_MANAGER = "M";
    public static final String ROLE_UNREGISTERED = "X";
    public static final String ROLE_REPRESENTATIVE = "E";
    public static final String ROLE_LTD_REPRESENTATIVE = "L";
    // role prefixes mappings to role values
    public static final int TYPE_LENGTH = 1;
    private static Roles roles;
    private Map<String, Integer> roleMappings = new HashMap<String, Integer>();

    private Roles() {
        roleMappings.put(ROLE_DUMBUSER, DUMBUSER);
        roleMappings.put(ROLE_PERMISSION_MANAGER, PERMISSION_MANAGER);
        roleMappings.put(ROLE_DEVELOPER, DEVELOPER);
        roleMappings.put(ROLE_PORTAL_MANAGER, PORTAL_MANAGER);
        roleMappings.put(ROLE_UNREGISTERED, UNREGISTERED);
        roleMappings.put(ROLE_REPRESENTATIVE, REPRESENTATIVE);
        roleMappings.put(ROLE_LTD_REPRESENTATIVE, LIMITED_REPRESENTATIVE);
    }

    /**
     * @return role mappings
     */
    public Map<String, Integer> getRoleMappings() {
        return roleMappings;
    }

    /**
     * @return roles instance
     */
    public static Roles instance() {
        if (roles == null) {
            roles = new Roles();
        }
        return roles;
    }

    /**
     * Decimal Binary 0 0000 no permissions 1 0001 dumbuser (useful) 2 0010 permission manager 3 0011 user + permmanager
     * (useful) 4 0100 developer 5 0101 user + developer (useful) 6 0110 permmanager + developer (permissions actually
     * equal 8) 7 0111 user + permmanager + developer (useful, equals 11) 8 1000 portal manager 9 1001 portal manager +
     * user(useful) 10 1010 portal manager + permission manager (no sense) 11 1011 portal manager + user + permission
     * manager 12 1100 portal manager + developer (no sense) 13 1101 portal manager + developer + user 14 1110 portal
     * manager + developer + permission manager (no sense at all) 15 1111 all permissions (useful)
     * 
     * 1, 3, 5, 9, 15 are useful options to store in db
     * 
     * @param role for which to find weakest role for
     * @return weakest role
     */
    public static int findWeakestRole(int role) {
        return getAllRolesSet(role).first();
    }

    // .... can set up to 31 (32-th is reserved for sign)

    /**
     * Checks if user has any rights
     * 
     * @param role role to check
     * @return true if user has any rights, false if user has NO_RIGHTS
     */
    public static boolean hasAnyRights(int role) {
        return role != NO_RIGHTS;
    }

    /**
     * Checks if given role is set
     * 
     * @param myRole
     *            role to check for
     * @param roleToCheck
     *            role to check against, Constant from RolesBitwise class
     * @return true if is set and false otherwise
     */
    public static boolean isSet(int myRole, int roleToCheck) {
        return (myRole & roleToCheck) == roleToCheck;
    }

    /**
     * Checks if any of given roles is set in base role
     * @param baseRole role to take as base
     * @param rolesToCheck array of roles to check for
     * @return true if any of given roles is set in baseRole, false otherwise
     */
    public static boolean isAnySet(int baseRole, int... rolesToCheck) {
        for (int i : rolesToCheck) {
            if (isSet(baseRole, i)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Iterates through all all possible roles and returns list of given roles
     * @param myRole role to check
     * @return set of roles set for myRole
     */
    public static SortedSet<Integer> getAllRolesSet(int myRole) {
        SortedSet<Integer> result = new TreeSet<Integer>();

        for (int i : ALL_REAL_ROLES) {
            if (isSet(myRole, i)) {
                result.add(i);
            }
        }
        // no roles set
        if (result.isEmpty()) {
            result.add(NO_RIGHTS);
        }

        return result;
    }

    /**
     * Calculates decimal value for specified roles list
     * @param rolesIn list of role integer values
     * @return role represented by decimals
     */
    public static int calculateRole(Set<Integer> rolesIn) {
        int role = 0;
        if (rolesIn != null && !rolesIn.isEmpty()) {
            for (Integer r : rolesIn) {
                role |= r;
            }
            LOGGER.debug("Calculated role = " + role);
        } else {
            role = 0;
            LOGGER.debug("roles = " + rolesIn + ". Setting role=" + role);
        }
        return role;
    }

    /**
     * Sums arbitary number of roles
     * 
     * @param role
     *            base role
     * @param addition
     *            roles to be added
     * @return resulting decimal representation of summed roles
     */
    public static int addRoles(int role, int... addition) {
        int result = role;
        for (int add : addition) {
            result |= add;
        }
        return result;
    }

    /**
     * Removes arbitary number of roles
     * 
     * @param role
     *            base role
     * @param removed
     *            roles to be removed
     * @return resulting decimal representation of role without removed roles
     */
    public static int removeRoles(int role, int... removed) {
        int result = role;
        LOGGER.debug("Old role = " + role);
        LOGGER.debug("Roles to be removed: " + removed);
        for (int rem : removed) {
            if (isSet(role, rem)) {
                LOGGER.debug(rem + " is set on " + role);
                result ^= rem;
            }
        }
        LOGGER.debug("New role = " + result);
        return result;
    }

    /**
     * @param oldRole role compared with
     * @param newRole role compared to
     * @return set of removed roles
     */
    public static Set<Integer> removedRoles(int oldRole, int newRole) {
        int roleDiff = oldRole ^ newRole;
        int removedRoles = roleDiff & oldRole;

        if (hasAnyRights(removedRoles)) {
            return getAllRolesSet(removedRoles);
        }
        return null;
    }

    /**
     * @param oldRole role compared with
     * @param newRole role compared to
     * @return  true if any role changed, false otherwise
     */
    public static boolean hasRoleChanged(int oldRole, int newRole) {
        return hasAnyRights(oldRole ^ newRole);
    }
    /**
     * Test if any of the certain roles in role collection have changed.
     * Similar to {@link #hasRoleChanged(int, int)},
     * but only applies to roles defined in #refRoles.
     * @param oldRoles first role collection
     * @param newRoles another role collection
     * @param refRoles array of reference roles.
     *                 The method compares if any of those reference roles
     *                 have changed between oldRoles and newRoles.
     * @return  true if certain roles in role collection have changed, false otherwise
     */
    public static boolean hasRoleChangedInReference(int oldRoles, int newRoles, int... refRoles) {
        for (int refRole : refRoles) {
            if (hasRoleChanged(oldRoles & refRole, newRoles & refRole)) {
                return true;
            }
        }
        return false;
    }

    /**
     * @param oldRole role compared with
     * @param newRole role compared to
     * @return set of roles added to newRole
     */
    public static Set<Integer> addedRoles(int oldRole, int newRole) {
        int roleDiff = oldRole ^ newRole;
        int addedRoles = roleDiff & newRole;

        if (hasAnyRights(addedRoles)) {
            return getAllRolesSet(addedRoles);
        }
        return null;
    }

    /**
     *
     * @param oldRole role compared with
     * @param role role compared to
     * @return true if manager was added, false if it wasn't, null if nothing even changed
     */
    public static Boolean wasManagerAdded(int oldRole, int role) {
        Boolean addedManager = null;
        // permission manager rights
        if (!Roles.isSet(oldRole, Roles.PERMISSION_MANAGER)) {
            if (Roles.isSet(role, Roles.PERMISSION_MANAGER)) {
                // user didn't have permission manager set b4 but has it now
                addedManager = Boolean.TRUE;
            }
        } else {
            // user had permission manager set b4
            if (!Roles.isSet(role, Roles.PERMISSION_MANAGER)) {
                // now it wasn't set
                addedManager = Boolean.FALSE;
            }
        }
        // portal manager rights
        if (!Roles.isSet(oldRole, Roles.PORTAL_MANAGER)) {
            if (Roles.isSet(role, Roles.PORTAL_MANAGER)) {
                // user didn't have portal manager set b4 but has it now
                addedManager = Boolean.TRUE;
            }
        } else {
            // user had portal manager set b4
            if (!Roles.isSet(role, Roles.PORTAL_MANAGER)) {
                // now it wasn't set
                addedManager = Boolean.FALSE;
            }
        }
        return addedManager;
    }

    /**
     * Find list of role codes that are not contained in reference roles.
     * @param role input role collection where missing codes are found
     * @param refRoles set of allowed role codes
     * @return return role codes from input role collection which are not in #refRoles
     */
    public static List<Integer> findUndefinedRoles(int role, Set<Integer> refRoles) {
        final int refRole = calculateRole(refRoles);
        final int undefinedRole = role & ~refRole;
        List<Integer> undefinedRoles = new ArrayList<Integer>();
        final int intBitLen = 32;
        for (int i = 0, ref = 1; i < intBitLen; i++, ref <<= 1) {
            if ((ref & undefinedRole) != 0) {
                undefinedRoles.add(ref);
            }
        }
        return undefinedRoles;
    }

}
