/*
 *  Created by Phil on 14/08/2012.
 *  Copyright 2012 Two Blue Cubes Ltd. All rights reserved.
 *
 *  Distributed under the Boost Software License, Version 1.0. (See accompanying
 *  file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 */
#ifndef TWOBLUECUBES_CATCH_TEST_CASE_INFO_HPP_INCLUDED
#define TWOBLUECUBES_CATCH_TEST_CASE_INFO_HPP_INCLUDED

#include "catch_tags.hpp"
#include "catch_test_case_info.h"
#include "catch_interfaces_testcase.h"
#include "catch_common.h"

namespace Catch {

    TestCase makeTestCase(  ITestCase* _testCase,
                            std::string const& _className,
                            std::string const& _name,
                            std::string const& _descOrTags,
                            SourceLineInfo const& _lineInfo )
    {
        std::string desc = _descOrTags;
        bool isHidden( startsWith( _name, "./" ) );
        std::set<std::string> tags;
        TagExtracter( tags ).parse( desc );
        if( tags.find( "hide" ) != tags.end() || tags.find( "." ) != tags.end() )
            isHidden = true;

        TestCaseInfo info( _name, _className, desc, tags, isHidden, _lineInfo );
        return TestCase( _testCase, info );
    }

    TestCaseInfo::TestCaseInfo( std::string const& _name,
                                std::string const& _className,
                                std::string const& _description,
                                std::set<std::string> const& _tags,
                                bool _isHidden,
                                SourceLineInfo const& _lineInfo )
    :   name( _name ),
        className( _className ),
        description( _description ),
        tags( _tags ),
        lineInfo( _lineInfo ),
        isHidden( _isHidden )
    {
        std::ostringstream oss;
        for( std::set<std::string>::const_iterator it = _tags.begin(), itEnd = _tags.end(); it != itEnd; ++it )
            oss << "[" << *it << "]";
        tagsAsString = oss.str();
    }

    TestCaseInfo::TestCaseInfo( TestCaseInfo const& other )
    :   name( other.name ),
        className( other.className ),
        description( other.description ),
        tags( other.tags ),
        tagsAsString( other.tagsAsString ),
        lineInfo( other.lineInfo ),
        isHidden( other.isHidden )
    {}

    TestCase::TestCase( ITestCase* testCase, TestCaseInfo const& info ) : TestCaseInfo( info ), test( testCase ) {}

    TestCase::TestCase( TestCase const& other )
    :   TestCaseInfo( other ),
        test( other.test )
    {}

    TestCase TestCase::withName( std::string const& _newName ) const {
        TestCase other( *this );
        other.name = _newName;
        return other;
    }

    void TestCase::invoke() const {
        test->invoke();
    }

    bool TestCase::isHidden() const {
        return TestCaseInfo::isHidden;
    }

    bool TestCase::hasTag( std::string const& tag ) const {
        return tags.find( toLower( tag ) ) != tags.end();
    }
    bool TestCase::matchesTags( std::string const& tagPattern ) const {
        TagExpression exp;
        TagExpressionParser( exp ).parse( tagPattern );
        return exp.matches( tags );
    }
    std::set<std::string> const& TestCase::getTags() const {
        return tags;
    }

    void TestCase::swap( TestCase& other ) {
        test.swap( other.test );
        className.swap( other.className );
        name.swap( other.name );
        description.swap( other.description );
        std::swap( lineInfo, other.lineInfo );
    }

    bool TestCase::operator == ( TestCase const& other ) const {
        return  test.get() == other.test.get() &&
                name == other.name &&
                className == other.className;
    }

    bool TestCase::operator < ( TestCase const& other ) const {
        return name < other.name;
    }
    TestCase& TestCase::operator = ( TestCase const& other ) {
        TestCase temp( other );
        swap( temp );
        return *this;
    }

    TestCaseInfo const& TestCase::getTestCaseInfo() const
    {
        return *this;
    }

} // end namespace Catch

#endif // TWOBLUECUBES_CATCH_TEST_CASE_INFO_HPP_INCLUDED
