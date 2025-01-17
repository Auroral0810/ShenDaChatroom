<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>聊天室维护界面</title>
  <%
    String currentUsername = (String) session.getAttribute("user");
    if (currentUsername == null) {
      response.sendRedirect("Loginbysql.jsp");
      return;
    }
  %>
  <!-- 引入Bootstrap CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body {
      margin:0;
      padding:0;
      /* 柔和的渐变背景 */
      background: linear-gradient(to bottom right, #8e9eab, #eef2f3);
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      min-height:100vh;
      display:flex;
      flex-direction:column;
    }

    nav.navbar {
      backdrop-filter: blur(8px);
      background: rgba(255,255,255,0.8)!important;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .navbar-brand {
      font-weight:600;
      color:#2c3e50 !important;
    }

    .nav-link {
      cursor: pointer;
      transition: color 0.3s ease;
      color:#2c3e50 !important;
    }
    .nav-link:hover {
      color:#3498db !important;
    }

    .content-container {
      margin-top: 20px;
      flex:1;
      display:flex;
      justify-content:center;
      align-items:center;
      padding:40px 20px;
    }

    /* 半透明卡片容器 */
    .card-container {
      background: rgba(255,255,255,0.85);
      backdrop-filter: blur(10px);
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.1);
      padding: 20px;
      width:100%;
      max-width: 1100px;
      display:flex;
      flex-direction:column;
      align-items: stretch;
    }

    iframe {
      width: 100%;
      height: 80vh;
      border: none;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
      background: #ffffff;
      transition: box-shadow 0.3s ease;
    }
    iframe:hover {
      box-shadow: 0 8px 30px rgba(0,0,0,0.15);
    }

    .return-button {
      background-color: #e74c3c;
      color:#fff;
      border:none;
      border-radius:20px;
      padding:6px 12px;
      transition: background-color 0.3s ease, transform 0.1s ease;
      margin-left:15px;
    }
    .return-button:hover {
      background-color:#c0392b;
      transform: scale(1.05);
    }

    .navbar-nav .nav-item .nav-link.active {
      color:#3498db !important;
      font-weight:600;
    }
  </style>
</head>
<body>
<!-- 顶部导航栏 -->
<nav class="navbar navbar-expand-lg navbar-light bg-white">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">聊天室维护</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
            data-bs-target="#navbarMaintenance" aria-controls="navbarMaintenance"
            aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarMaintenance">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <!-- 修改用户的基本信息 -->
        <li class="nav-item">
          <a class="nav-link active" aria-current="page" onclick="loadPage('UserInfoMaintenance.jsp')">
            修改用户信息
          </a>
        </li>
        <!-- 修改用户密码 -->
        <li class="nav-item">
          <a class="nav-link" onclick="loadPage('ChangePassword.jsp')">
            修改用户密码
          </a>
        </li>
        <!-- 聊天记录管理（含导出功能） -->
        <li class="nav-item">
          <a class="nav-link" onclick="loadPage('ChatRecordManagement.jsp')">
            聊天记录管理
          </a>
        </li>
        <!-- 敏感词维护（添加、删除、修改） -->
        <li class="nav-item">
          <a class="nav-link" onclick="loadPage('SensitiveWordsMaintenance.jsp')">
            敏感词维护
          </a>
        </li>
      </ul>
      <!-- 返回聊天室按钮 -->
      <form class="d-flex">
        <button type="button" class="return-button" onclick="location.href='AdminChat.jsp'">返回聊天室</button>
      </form>
    </div>
  </div>
</nav>

<div class="content-container">
  <div class="card-container">
    <!-- 使用iframe显示对应的维护界面 -->
    <iframe id="maintenanceFrame" src="UserInfoMaintenance.jsp"></iframe>
  </div>
</div>

<!-- 引入Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function loadPage(pageUrl) {
    var frame = document.getElementById('maintenanceFrame');
    frame.src = pageUrl;
    // 移除之前的active状态
    var links = document.querySelectorAll('.navbar-nav .nav-link');
    links.forEach(function(link){
      link.classList.remove('active');
    });
    // 给当前点击的链接添加active
    event.target.classList.add('active');
  }
</script>
</body>
</html>
