<%@ page import="java.util.*,java.text.*,java.sql.*" contentType="text/html;charset=UTF-8" language= "java" %>

<html lang="en">
<head>
    <script src="jquery-3.7.1.min.js"></script>
    <script language="JavaScript">
        // 全局变量存储验证码
        var generatedCaptcha = "";
        var MyTime1; // 移动到全局变量

        function init() {
            document.reg_form.usrname.focus();
            generateCaptcha();
            initializeClock();
        }

        function Verify()   //校验用户输入
        {
            if (VerifyUsrName() == false) return false;       	//校验用户名
            if (VerifyPasswd() == false) return false;         	//校验密码
            if (VerifyDepart() == false) return false;          	//校验单位名称
            if (VerifyAddr() == false) return false;           	//校验地址
            if (VerifyPersonName() == false) return false;     	//校验联系人姓名
            if (VerifyPhone() == false) return false;          	//校验电话号码
            if (VerifyIDCard() == false) return false;           //校验身份证信息
            if (VerifyZip() == false) return false;            	//校验邮编
            if (Verifybpcode() == false) return false;          //校验寻呼号
            if (VerifyFax() == false) return false;            	//校验传真号
            if (VerifyHand() == false) return false;           	//校验手机号
            if (VerifyEmail() == false) return false;           	//校验电子邮件地址
            if (VerifyHomepage() == false) return false;       	//校验主页地址
            if (VerifyQuest() == false) return false;           	//校验忘记密码时所提问题
            if (VerifyAnsw() == false) return false;            	//校验问题答案
            if (VerifyCaptcha() == false) return false;          //校验验证码
            return true;
        }

        function VerifyUsrName() {
            var name = document.reg_form.usrname.value;

            // 检查用户名是否为空
            if (name.length === 0) {
                alert("用户名不能为空!请见左边的说明，输入合法的用户名。");
                return false;
            }

            // 定义用户名正则表达式
            const usernameRegex = /^[a-zA-Z][a-zA-Z0-9_]{3,15}$/;

            // 检查用户名是否符合正则表达式
            if (!usernameRegex.test(name)) {
                alert("您输入的用户名中包含了不合法的字符!请见左边的说明，重新输入。");
                return false;
            }

            // 如果所有检查都通过，则返回 true
            return true;
        }

        function VerifyPasswd(){
            if(document.reg_form.pass.value.length==0){
                alert("密码不能为空！请见左边的说明，输入合法的密码。");
                return false;
            }
            if(document.reg_form.pass.value.length>12){
                alert("密码长度不能超过12位！请见左边的说明，重新输入密码。");
                return false;
            }
            if(document.reg_form.pass2.value.length==0){
                alert("确认密码不能为空！请再次输入密码。");
                return false;
            }
            if(document.reg_form.pass2.value !== document.reg_form.pass.value){
                alert("两次输入的密码不同，请重新输入！");
                return false;
            }
            return true;
        }

        function VerifyDepart(){
            if(document.reg_form.dname.value.length==0){
                alert("单位名称不能为空！请输入您目前工作的单位名称。")
                return false;
            }
            return true;
        }

        function VerifyPersonName() {
            if(document.reg_form.person_name.value.length==0){
                alert("联系人姓名不能为空！请输入您的姓名。");
                return false;
            }
            if(ValidOfPersonName()==false){
                alert("联系人姓名不合法，应该为汉字或者英文。");
                return false;
            }
            return true;
        }

        function ValidOfPersonName( ){	    //检验用户输入的用户名中是否包含非法字符
            var test_name = document.reg_form.person_name.value;
            var reg =/^([\u4e00-\u9fa5]+|([a-zA-Z]+\s?)+)$/g;// /^[\一-\?]*$/g , reg2 = /^[A-Za-z]+$/;

            if(reg.test(test_name)){
                return true;
            }else{
                return false;
            }
        }

        function VerifyPhone() {
            var phone = document.reg_form.tel.value;
            if(phone.length!=0)
            {
                var reg = /^0\d{2,3}-\d{7,8}$/
                if(reg.test(phone)){
                    return true;
                }else{
                    alert('电话号码格式错误，请重新输入！');
                    return false;
                }
            }
            return true;
        }

        function VerifyHand() {
            // 获取移动电话输入框的值
            var phoneNumber = document.reg_form.hand.value;

            // 检查移动电话是否为空
            if (phoneNumber.length === 0) {
                alert("移动电话不能为空！请输入您的移动电话。");
                return false;
            }

            // 定义手机号正则表达式
            const phoneRegex = /^1[34578]\d{9}$/;

            // 使用test方法检查手机号是否符合格式
            if (phoneRegex.test(phoneNumber)) {
                return true;
            } else {
                alert('移动电话格式错误，请重新输入');
                return false;
            }
        }

        function VerifyIDCard() {
            if(document.reg_form.IDcard.value.length==0){
                alert("身份证信息不能为空！请输入您的身份证号码。");
                return false;
            }
            var idcard=document.reg_form.IDcard.value;
            if(validateIDCard(idcard)==false){
                alert("身份证信息输入不合法！请重新输入合法的身份证号码。");
                return false;
            }
            return true;
        }

        function validateIDCard(idCard) {
            // 正则表达式验证格式
            const pattern = /^[1-9]\d{5}(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}(\d|X)$/;

            if (!pattern.test(idCard)) {
                return false;
            }

            // 验证校验位
            const modWeight = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]; // 权重
            const modCheckDigit = [1, 0, 'X', 9, 8, 7, 6, 5, 4, 3, 2]; // 校验位映射

            const idArray = idCard.split('');
            let sum = 0;
            for (let i = 0; i < 17; i++) {
                sum += parseInt(idArray[i]) * modWeight[i];
            }

            const mod = sum % 11;
            const checkDigit = modCheckDigit[mod];

            return idArray[17].toUpperCase() == checkDigit.toString();
        }

        function VerifyEmail() {
            if(document.reg_form.email.value.length!=0){
                //使用国际标准进行验证
                const emailRFC2822= /^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
                var email=document.reg_form.email.value;
                if(emailRFC2822.test(email)){
                    return true;
                }else {
                    alert('邮箱格式不符合RFC2822国际规范，请重新输入合法的邮箱号');
                    return false;
                }
            }
            return true;
        }

        function VerifyZip() {
            if(document.reg_form.postcode.value.length==0){
                alert("邮编不能为空！请输入您的邮编。");
                return false;
            }
            var postCode = document.reg_form.postcode.value;
            var reg = /^[1-9]\d{5}(?!\d)$/g;
            if(reg.test(postCode)){
                return true;
            }else{
                alert("邮编不存在，请重新输入邮编。");
                return false;
            }
        }

        function Verifybpcode() {
            // 获取寻呼号码输入框的值
            var bpcode = document.reg_form.bpcode.value;

            // 如果寻呼号码不为空，则进行验证
            if (bpcode.length != 0) {
                // 使用正则表达式进行匹配验证
                var pattern = /^\d{7,10}$/;  // 匹配7到10位的数字

                // 检查寻呼号码是否符合正则表达式
                if (!pattern.test(bpcode)) {
                    alert("寻呼输入不合理！请重新输入。");
                    return false;
                }
            }

            return true;
        }

        function VerifyFax() {
            if(document.reg_form.fax.value.length!=0){
                var faxNumber=document.reg_form.fax.value;
                // 使用正则表达式进行匹配验证
                var pattern = /^\d{1,3}-\d{1,3}-\d{4}$/;
                if(pattern.test(faxNumber)==false){
                    alert("传真输入不合理！请重新输入。");
                    return false;
                }
            }
            return true;
        }

        function VerifyQuest() {
            // 获取忘记密码问题输入框的值
            var quest = document.reg_form.quest.value;
            if (quest.length == 0) {
                alert("忘记密码问题不能为空，请重新输入！");
                return false;
            }
            // 如果忘记密码问题不为空，则进行验证
            if (quest.length != 0) {
                // 检查问题长度是否在合理范围内
                if (quest.length < 5 || quest.length > 100) {
                    alert("忘记密码问题长度应在5到100个字符之间！");
                    return false;
                }

                // 检查问题中是否包含非法字符
                if (!/^[a-zA-Z0-9\u4e00-\u9fa5\s,.\?!:;'"-]+$/.test(quest)) {
                    alert("忘记密码问题包含非法字符！请只使用字母、数字、汉字和常用标点符号。");
                    return false;
                }
            }
            return true;
        }

        function VerifyAnsw() {
            // 获取忘记密码问题答案输入框的值
            var answ = document.reg_form.answ.value;

            // 如果忘记密码问题答案不为空，则进行验证
            if (answ.length != 0) {
                // 检查答案长度是否在合理范围内
                if (answ.length < 5 || answ.length > 100) {
                    alert("忘记密码问题答案长度应在5到100个字符之间！");
                    return false;
                }

                // 检查答案中是否包含非法字符
                if (!/^[a-zA-Z0-9\u4e00-\u9fa5\s,.\?!:;'"-]+$/.test(answ)) {
                    alert("忘记密码问题答案包含非法字符！请只使用字母、数字、汉字和常用标点符号。");
                    return false;
                }
            }
            return true;
        }

        function VerifyHomepage() {
            if(document.reg_form.homepg.value.length!=0){
                const regex = /^(https?|ftp):\/\/([a-zA-Z0-9.-]+(\:[0-9]+)?)(\/[a-zA-Z0-9%_.~+-]+)*\/?(\?[a-zA-Z0-9%_.,~+-=&]*)?(#[a-zA-Z0-9_-]+)?$/;
                var url=document.reg_form.homepg.value;
                if(regex.test(url)==false){
                    alert("主页地址输入不是有效的URL地址，请重新输入！");
                    return false;
                }
                else{
                    return true;
                }
            }
            return true;
        }

        function VerifyAddr() {
            var provinceVal = document.reg_form.province.value;
            var cityVal = document.reg_form.city.value;
            var districtVal = document.reg_form.district.value;

            if (provinceVal === "") {
                alert("请选择省份");
                return false;
            }
            if (cityVal === "") {
                alert("请选择城市");
                return false;
            }
            if (districtVal === "") {
                alert("请选择城区");
                return false;
            }
            return true;
        }

        // 新增的验证码验证函数
        function VerifyCaptcha() {
            var userCaptcha = document.reg_form.captcha_input.value.trim();
            if (userCaptcha.length === 0) {
                alert("验证码不能为空，请输入验证码！");
                return false;
            }
            if (userCaptcha.toLowerCase() !== generatedCaptcha.toLowerCase()) {
                alert("验证码输入错误，请重新输入！");
                generateCaptcha(); // 刷新验证码
                return false;
            }
            return true;
        }

        // 生成验证码的函数
        function generateCaptcha() {
            var canvas = document.getElementById("captchaCanvas");
            var ctx = canvas.getContext("2d");
            var charsArray = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
            var lengthOtp = 6;
            var captcha = [];
            for (var i = 0; i < lengthOtp; i++) {
                var index = Math.floor(Math.random() * charsArray.length);
                if (captcha.indexOf(charsArray[index]) == -1)
                    captcha.push(charsArray[index]);
                else i--;
            }
            generatedCaptcha = captcha.join("");
            // 清空Canvas
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            // 填充背景
            ctx.fillStyle = "#f2f2f2";
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            // 添加干扰线
            for (var i = 0; i < 5; i++) {
                ctx.strokeStyle = getRandomColor();
                ctx.beginPath();
                ctx.moveTo(Math.random() * canvas.width, Math.random() * canvas.height);
                ctx.lineTo(Math.random() * canvas.width, Math.random() * canvas.height);
                ctx.stroke();
            }
            // 设置验证码文字
            ctx.font = "25px Arial";
            ctx.fillStyle = "#333";
            ctx.textBaseline = "middle";
            var x = 10;
            for (var i = 0; i < generatedCaptcha.length; i++) {
                var y = canvas.height / 2;
                var angle = Math.random() * 0.4 - 0.2; // -0.2 到 0.2 弧度
                ctx.save();
                ctx.translate(x, y);
                ctx.rotate(angle);
                ctx.fillText(generatedCaptcha[i], 0, 0);
                ctx.restore();
                x += 30;
            }
        }

        // 生成随机颜色
        function getRandomColor() {
            var letters = '0123456789ABCDEF';
            var color = '#';
            for (var i = 0; i < 6; i++) {
                color += letters[Math.floor(Math.random() * 16)];
            }
            return color;
        }

        function Submit() {
            var form = document.forms['reg_form'];

            if (!Verify()) {
                return false; // 如果验证失败，阻止表单提交
            }

            // 设置隐藏字段的值为选中的文本
            document.getElementById('hiddenProvince').value = form.elements['province'].options[form.elements['province'].selectedIndex].text || "null";
            document.getElementById('hiddenCity').value = form.elements['city'].options[form.elements['city'].selectedIndex].text || "null";
            document.getElementById('hiddenDistrict').value = form.elements['district'].options[form.elements['district'].selectedIndex].text || "null";

            // 收集表单数据
            var formData = new FormData(form);
            var infoObject = {};

            // 添加省、市、区信息
            infoObject['province'] = document.getElementById('hiddenProvince').value;
            infoObject['city'] = document.getElementById('hiddenCity').value;
            infoObject['district'] = document.getElementById('hiddenDistrict').value;

            // 收集其余表单字段
            for (var pair of formData.entries()) {
                if (pair[0] !== 'province' && pair[0] !== 'city' && pair[0] !== 'district' && pair[0] !== 'provinceText' && pair[0] !== 'cityText' && pair[0] !== 'districtText') {
                    infoObject[pair[0]] = pair[1] === "" ? "null" : pair[1];
                }
            }

            // 存储到sessionStorage
            sessionStorage.setItem("registeredUsername", infoObject["usrname"]);
            sessionStorage.setItem("registeredPassword", infoObject["pass"]);
            sessionStorage.setItem("registeredPersonName", infoObject["person_name"]);
            sessionStorage.setItem("registeredGender", form.elements["gender"].value);
            sessionStorage.setItem("registeredTel", infoObject["tel"]);
            sessionStorage.setItem("registeredPostcode", infoObject["postcode"]);
            sessionStorage.setItem("registeredBpcode", infoObject["bpcode"]);
            sessionStorage.setItem("registeredFax", infoObject["fax"]);
            sessionStorage.setItem("registeredHand", infoObject["hand"]);
            sessionStorage.setItem("registeredIDcard", infoObject["IDcard"]);
            sessionStorage.setItem("registeredEmail", infoObject["email"]);
            sessionStorage.setItem("registeredHomepg", infoObject["homepg"]);
            sessionStorage.setItem("registeredProvince", infoObject["province"]);
            sessionStorage.setItem("registeredCity", infoObject["city"]);
            sessionStorage.setItem("registeredDistrict", infoObject["district"]);

            // 提交表单到SaveToSql.jsp
            form.action = "SaveToSql.jsp";
            form.setAttribute("accept-charset", "UTF-8");
            alert("注册成功！即将返回登陆界面进行登陆……");
            form.submit();

            return false; // 阻止默认提交
        }

        // 初始化时记录时间
        function initializeClock() {
            var MyDate1 = new Date();
            var MyHours1 = MyDate1.getHours();
            var MyMinutes1 = MyDate1.getMinutes();
            var MySeconds1 = MyDate1.getSeconds();
            MyTime1 = MyDate1.getTime();
            window.document.write("<center>", "注册成功的时间是: ",
                MyDate1.getFullYear(), '年', MyDate1.getMonth() + 1, '月',
                MyDate1.getDate(), '日', MyHours1, '时',
                MyMinutes1, '分', MySeconds1, '秒', "<center>");
        }
    </script>
    <style>
        body {
            font-family: 'Arial', 'Microsoft YaHei', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            display: flex;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            max-width: 1000px;
            width: 100%;
        }
        .instructions {
            background-color: #f9f0f0;
            padding: 20px;
            width: 300px;
            color: #333;
            border-right: 1px solid #e0e0e0;
        }
        .instructions h2 {
            color: #8b0000;
            margin-bottom: 15px;
            border-bottom: 2px solid #8b0000;
            padding-bottom: 10px;
        }
        .instructions ul {
            list-style-type: none;
            padding: 0;
        }
        .instructions li {
            margin-bottom: 10px;
            display: flex;
            align-items: center;
        }
        .instructions li::before {
            content: '★';
            color: #8b0000;
            margin-right: 10px;
        }
        .registration-form {
            flex-grow: 1;
            padding: 20px;
        }
        .form-title {
            text-align: center;
            color: #8b0000;
            margin-bottom: 20px;
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 15px;
        }
        .form-group label {
            margin-bottom: 5px;
            color: #333;
        }
        input[type="text"],
        input[type="password"],
        input[type="email"],
        select {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            transition: border-color 0.3s;
        }
        input[type="text"]:focus,
        input[type="password"]:focus,
        input[type="email"]:focus,
        select:focus {
            outline: none;
            border-color: #8b0000;
        }
        .form-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }
        .form-actions input[type="submit"],
        .form-actions input[type="reset"] {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .form-actions input[type="submit"] {
            background-color: #8b0000;
            color: white;
        }
        .form-actions input[type="submit"]:hover {
            background-color: #6b0000;
        }
        .form-actions input[type="reset"] {
            background-color: #ddd;
            color: #333;
        }
        .form-actions input[type="reset"]:hover {
            background-color: #ccc;
        }
        /* 新增的验证码样式 */
        .captcha-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #captchaCanvas {
            border: 1px solid #ddd;
            cursor: pointer;
            border-radius: 5px;
        }
        .captcha-tip {
            font-size: 12px;
            color: #555;
            margin-top: 5px;
        }
        /* 调整验证码输入框 */
        .captcha-input {
            flex: 1;
        }
    </style>
</head>
<body onload="init()">
<div class="container">
    <div class="instructions">
        <h2>注册说明</h2>
        <ul>
            <li>为保证您今后在本网发布的供求信息的可靠性，请如实填写会员信息表。</li>
            <li>必须填写的基本信息：用户名、密码、忘记密码后查询密码的问题、单位名称、联系人、地址、邮编、电话。</li>
            <li>用户名：16个字符以内的英文字母数字串，可包含下划线"_"</li>
            <li>密码：12个字符以内的任意字符串</li>
            <li>其他信息若您具备，最好也填写，以便于联系。</li>
        </ul>
    </div>
    <div class="registration-form">
        <h1 class="form-title">用户注册</h1>
        <form action="SaveToSql.jsp" method="post" name="reg_form" onsubmit="return Submit()">
            <!-- 新增的隐藏字段 -->
            <input type="hidden" name="provinceText" id="hiddenProvince">
            <input type="hidden" name="cityText" id="hiddenCity">
            <input type="hidden" name="districtText" id="hiddenDistrict">

            <div class="form-grid">
                <div class="form-group">
                    <label>用户名</label>
                    <input type="text" name="usrname" placeholder="请输入用户名" maxlength="16">
                </div>
                <div class="form-group">
                    <label>性别</label>
                    <div>
                        <input type="radio" name="gender" value="男" checked> 男
                        <input type="radio" name="gender" value="女"> 女
                    </div>
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" name="pass" placeholder="请输入密码" maxlength="12">
                </div>
                <div class="form-group">
                    <label>确认密码</label>
                    <input type="password" name="pass2" placeholder="再次输入密码" maxlength="12">
                </div>
            </div>

            <div class="form-group">
                <label>单位名称</label>
                <input type="text" name="dname" placeholder="请输入单位名称">
            </div>

            <div class="form-group">
                <label>联系地址</label>
                <div class="form-grid">
                    <select id="province" name="province">
                        <option value="">请选择省份</option>
                    </select>
                    <select id="city" name="city">
                        <option value="">请选择城市</option>
                    </select>
                    <select id="district" name="district">
                        <option value="">请选择城区</option>
                    </select>
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>联系人姓名</label>
                    <input type="text" name="person_name" placeholder="请输入联系人姓名">
                </div>
                <div class="form-group">
                    <label>电话</label>
                    <input type="text" name="tel" placeholder="区号+号码">
                </div>
                <div class="form-group">
                    <label>邮编</label>
                    <input type="text" name="postcode" placeholder="邮政编码">
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>寻呼</label>
                    <input type="text" name="bpcode">
                </div>
                <div class="form-group">
                    <label>传真</label>
                    <input type="text" name="fax">
                </div>
                <div class="form-group">
                    <label>移动电话</label>
                    <input type="text" name="hand">
                </div>
            </div>

            <div class="form-group">
                <label>身份证</label>
                <input type="text" name="IDcard">
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>E-mail</label>
                    <input type="email" name="email" placeholder="请输入电子邮件">
                </div>
                <div class="form-group">
                    <label>主页</label>
                    <input type="text" name="homepg" placeholder="个人主页地址">
                </div>
            </div>

            <div class="form-group">
                <label>忘记密码后查询时的问题</label>
                <input type="text" name="quest" placeholder="设置密码找回问题">
            </div>

            <div class="form-group">
                <label>忘记密码后查询问题的答案</label>
                <input type="text" name="answ" placeholder="设置问题的答案">
            </div>

            <!-- 新增的验证码部分 -->
            <div class="form-group">
                <label>验证码</label>
                <div class="captcha-group">
                    <input type="text" name="captcha_input" class="captcha-input" placeholder="输入上图验证码">
                    <canvas id="captchaCanvas" width="200" height="50" title="点击刷新验证码" onclick="generateCaptcha()"></canvas>
                </div>
                <small class="captcha-tip">如遇加载失败，请点击验证码刷新！</small>
            </div>

            <div class="form-actions">
                <input type="submit" value="发送">
                <input type="reset" value="重填">
            </div>
        </form>
        <br>
        <center>
            <div id="Clock" style="font-family:'楷体'; font-size:30px;color:#0000FF" onclick="Eclock()">
                单击此处启动数字钟并统计网页持续时间
            </div>
        </center>
        <h2>
            <font color="green" face="楷体">
                <script language="JavaScript" type="text/javascript">
                    <!--
                    // 移除 MyDate1 的声明，这部分已在 initializeClock 中处理
                    //var MyDate1 = new Date();
                    //var MyHours1 = MyDate1.getHours();
                    //var MyMinutes1 = MyDate1.getMinutes();
                    //var MySeconds1 = MyDate1.getSeconds();
                    //var MyTime1 = MyDate1.getTime();
                    // 在 initializeClock 中调用 document.write，避免重复
                    // -->
                </script>
            </font>
        </h2>
    </div>
</div>
<script>
    window.onload = function () {
        // 获取省、市、区下拉框元素
        var provinceSelect = document.getElementById('province');
        var citySelect = document.getElementById('city');
        var districtSelect = document.getElementById('district');

        // 获取并设置省份的中文文本到隐藏域
        var provinceText = provinceSelect.options[provinceSelect.selectedIndex].text || "null";
        document.getElementById('hiddenProvince').value = provinceText;

        // 获取并设置城市的中文文本到隐藏域
        var cityText = citySelect.options[citySelect.selectedIndex].text || "null";
        document.getElementById('hiddenCity').value = cityText;

        // 获取并设置区的中文文本到隐藏域
        var districtText = districtSelect.options[districtSelect.selectedIndex].text || "null";
        document.getElementById('hiddenDistrict').value = districtText;
    };
</script>
<script type="text/javascript" src="data.js"></script>
<script type="text/javascript">
    var province = $("#province");
    var city = $("#city");
    var district = $("#district");
    // 初始化省份下拉选择框选项
    $(function() {
        data.forEach(function(value, index) {
            var provinceName = value.name;
            $('#province').append("<option value='" + index + "'>" + provinceName + "</option>");
        });
    });

    // 省份下拉框切换事件，加载城市下拉框
    $('#province').change(function() {
        // 清除城市和区县下拉框的选项
        $('#city').empty().append("<option value=''>请选择城市</option>");
        $('#district').empty().append("<option value=''>请选择城区</option>");

        var provinceIndex = $(this).val();
        if (provinceIndex !== "") {
            var cityList = data[provinceIndex].city;
            cityList.forEach(function(value, index) {
                $('#city').append("<option value='" + index + "'>" + value.name + "</option>");
            });
        }
    });

    // 城市下拉框切换事件，加载区县下拉框
    $('#city').change(function() {
        $('#district').empty().append("<option value=''>请选择城区</option>");

        var provinceIndex = $('#province').val();
        var cityIndex = $(this).val();
        if (provinceIndex !== "" && cityIndex !== "") {
            var districtList = data[provinceIndex].city[cityIndex].area;
            districtList.forEach(function(value, index) {
                $('#district').append("<option value='" + index + "'>" + value + "</option>");
            });
        }
    });

    // 重置表单时清除省市区选择框内容
    $("input[type='reset']").click(function() {
        // 重置表单字段
        $("form[name='reg_form']")[0].reset();

        // 清除省市区下拉框选项
        $('#province').val("").change(); // 触发change事件来清空城市和区县
        $('#city').empty().append("<option value=''>请选择城市</option>");
        $('#district').empty().append("<option value=''>请选择城区</option>");

        // 重新生成验证码
        generateCaptcha();
    });

    function Eclock() {
        var MyDate2 = new Date();
        var MyTime2 = MyDate2.getTime();
        var TimeString2 = '时钟: ' + MyDate2.getHours() + '时' + MyDate2.getMinutes() + '分' + MyDate2.getSeconds() + '秒';
        var MyHours3 = 0; var MyMinutes3 = 0;
        // MyTime1 已在全局变量中初始化
        // 当前 MySeconds4 为两者时间的时间差，单位为秒，1秒=1000毫秒，所以除以 1000
        var MySeconds4 = Math.floor((MyTime2 - MyTime1) / 1000);
        // 当前 MyHours3 为两者时间相差的小时数
        MyHours3 = Math.floor(MySeconds4 / 3600);
        // MyMinutes3 为分钟，取余3600再除以60
        MyMinutes3 = Math.floor((MySeconds4 % 3600) / 60);
        // MySeconds3 为最终的秒位上的值
        var MySeconds3 = MySeconds4 % 60;
        var TimeString3 = '页面持续时间是:' + MyHours3 + '时' + MyMinutes3 + '分' + MySeconds3 + '秒';
        Clock.innerHTML = TimeString2 + '<p>' + TimeString3;
        setTimeout(Eclock, 1000);
    }
</script>
</body>
</html>
