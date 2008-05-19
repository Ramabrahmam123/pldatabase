/*
 * Copyright (c) 2008 Plausible Labs.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of any contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "PlausibleDatabase.h"

/**
 * @internal
 *
 * SQL statement builder.
 */
@implementation PLSqlBuilder

/**
 * Initialize with the given database and dialect.
 *
 * @param database Database to use for generating prepared statements.
 * @param dialect Database dialect definition.
 */
- (id) initWithDatabase: (NSObject<PLDatabase> *) database dialect: (PLEntityDialect *) dialect {
    if ((self = [super init]) == nil)
        return nil;

    _db = [database retain];
    _dialect = [dialect retain];
    
    return self;
}

- (void) dealloc {
    [_db release];
    [_dialect release];

    [super dealloc];
}


/**
 * @internal
 * Create an INSERT prepared statement, with named bindings for the given column names.
 *
 * @param tableName The name of the table for the INSERT.
 * @param columns A list of all the column names, which will be included in the INSERT as named parameters.
 * @param outError If an error occurs, nil will be returned and outError will be populated with the error reason.
 * @return A prepared statement that may be used for dictionary-based parameter binding. Nil if an error occurs.
 */
- (NSObject<PLPreparedStatement> *) insertForTable: (NSString *) tableName withColumns: (NSArray *) columnNames error: (NSError **) outError {
    NSString *query;
    NSObject<PLPreparedStatement> *stmt;

    /* Create the query string */
    query = [NSString stringWithFormat: @"INSERT INTO %@ (%@) VALUES (:%@)", 
             [_dialect quoteIdentifier: tableName],
             [columnNames componentsJoinedByString: @", "],
             [columnNames componentsJoinedByString: @", :"]];

    /* Prepare the statement */
    stmt = [_db prepareStatement: query error: outError];
    if (stmt == nil)
        return nil;

    /* All is well in prepared statement land */
    return stmt;
}


@end