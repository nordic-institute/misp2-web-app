package ee.aktors.misp2.util;

import static org.junit.Assert.*;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.Test;

/**
 * Test {@link #Roles} class functionality.
 * @author sander
 *
 */
public class RolesTest {

    /**
     * Make sure #findUndefinedRoles(int, Set) is able to find list of roles
     * from input role collection that do not exist in allowedRoles collection.
     */
    @Test
    public void testFindUndefinedRoles() {
        int roles = 1 | 2 | 4 | 8 | 16 | 32;
        Set<Integer> allowedRoles = new HashSet<>(Arrays.asList(2, 8, 32));
        List<Integer> undefinedRoles = Roles.findUndefinedRoles(roles, allowedRoles);
        assertEquals(Arrays.asList(1 , 4 , 16), undefinedRoles);
    }

}
