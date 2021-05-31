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
package ee.aktors.misp2.util.persistence;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.type.EnumType;

/**
 * Enables using PostgreSQL enums in JPA entities. Usage example:
 * 
 * import org.hibernate.annotations.Type;
 * import org.hibernate.annotations.TypeDef;
 * @Entity
 * @Table(name = "example")
 * @TypeDef(
 *    name = "pgsql_enum",
 *    typeClass = ee.aktors.misp2.util.persistence.PostgreSQLEnumType.class
 * )
 * public class Example extends GeneralBean {
 * 
 *     @Enumerated(EnumType.STRING)
 *     @Type(type = "pgsql_enum")
 *     @Column(name = "enum_column")
 *     private MyEnum myEnum;
 *     enum MyEnum {VAL1, VAL2};
 *     ...
 *
 */
public class PostgreSQLEnumType extends EnumType {
    private static final long serialVersionUID = 1L;

    public void nullSafeSet(
            PreparedStatement st, 
            Object value, 
            int index, 
            SharedSessionContractImplementor session) 
        throws HibernateException, SQLException {
        if(value == null) {
            st.setNull( index, Types.OTHER );
        }
        else {
            st.setObject( 
                index, 
                value.toString(), 
                Types.OTHER 
            );
        }
    }
}
