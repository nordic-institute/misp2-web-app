<%@ taglib prefix="s" uri="/struts-tags" %>
<%@page pageEncoding="UTF-8" %>

<%--
  ~ The MIT License
  ~ Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
  ~ Copyright (c) 2019 Estonian Information System Authority (RIA)
  ~
  ~ Permission is hereby granted, free of charge, to any person obtaining a copy
  ~ of this software and associated documentation files (the "Software"), to deal
  ~ in the Software without restriction, including without limitation the rights
  ~ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  ~ copies of the Software, and to permit persons to whom the Software is
  ~ furnished to do so, subject to the following conditions:
  ~
  ~ The above copyright notice and this permission notice shall be included in
  ~ all copies or substantial portions of the Software.
  ~
  ~ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  ~ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  ~ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  ~ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  ~ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  ~ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  ~ THE SOFTWARE.
  ~
  --%>

<s:set var="lang" value="locale.language"/>

<div class="contentbox">
    <div class="row">
        <h3>1. Insert data (base64 encoded)</h3>
        <div class="col-md-7">
            <label for="DataToSign">Data:</label>
            <input id="DataToSign" type="text" value="PG5vdGU+Cjx0bz5Ub3ZlPC90bz4KPGZyb20+SmFuaTwvZnJvbT4KPGhlYWRpbmc+UmVtaW5kZXI8L2hlYWRpbmc+Cjxib2R5PkRvbid0IGZvcmdldCBtZSB0aGlzIHdlZWtlbmQhPC9ib2R5Pgo8L25vdGU+">
        </div>
        <div class="col-md-7">
            <label for="FileName">Name:</label>
            <input id="FileName" type="text" value="Encoded.xml">
        </div>
    </div>
    <div class="row">
        <div class="col-md-7">
            <h3>2. Sign with appropriate method to login method</h3>
            <button class="btn" id="signLoginButton" type="button">signAsLoggedIn()</button>
        </div>
    </div>
    <div class="row">
        <div class="col-md-7">
            <h3>3. Sign with ID-card</h3>
            <button class="btn" id="signButton" type="button">signDataCard()</button>
        </div>
    </div>
    <div class="row">
        <h3>4. Phone number</h3>
        <div class="col-md-7">
            <label for="PhoneNumber">Phone nr:</label>
            <input id="PhoneNumber" type="text" value="+37200000766">
        </div>
        <div class="col-md-7">
            <label for="IdentityCode">Id code:</label>
            <input id="IdentityCode" type="text" value="60001019906">
        </div>
    </div>
    <div class="row">
        <div class="col-md-7">
            <h3>5. Sign with mobile</h3>
            <button class="btn" id="signMobileButton" type="button">signDataMobile()</button>
        </div>
    </div>

    <div class="row">
        <div class="col-md-7">
            <h3>6. Download bdoc</h3>
            <s:url action="downloadContainer" var="downloadContainer"/>
            <s:a href="%{#downloadContainer}" data-confirmable-post-link="" class="button">Download bdoc</s:a>
        </div>
    </div>

</div>

<script type="text/javascript">
  $(document).on("click", "#signButton", function (event) {
    event.preventDefault();

    window.mispcrypto.signDataCard($("#DataToSign").val(), $("#FileName").val())
    .then(function (container) {
      console.log("Received encoded container signDataCard call:", {container: container});
    })
    .catch(function (error) {
      console.log("Caught error from signDataCard call.", error)
    });
  });

  $(document).on("click", "#signMobileButton", function (event) {
    event.preventDefault();

    window.mispcrypto.signDataMobile($("#DataToSign").val(), $("#FileName").val(), $("#PhoneNumber").val(), $("#IdentityCode").val())
    .then(function (container) {
      console.log("Received encoded container from signDataMobile call:", {container: container});
    })
    .catch(function (error) {
      console.log("Caught error from signDataMobile call.", error)
    });
  });

  $(document).on("click", "#signLoginButton", function (event) {
    event.preventDefault();
    window.mispcrypto.signData($("#DataToSign").val(), $("#FileName").val())
    .then(function (container) {
      console.log("Received encoded container from signData call:", {container: container});
    })
    .catch(function (error) {
      console.log("Caught error from signData call.", error)
    });
  });

</script>