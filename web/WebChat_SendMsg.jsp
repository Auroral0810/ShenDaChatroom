<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8" import="java.util.*,java.util.Date,java.text.SimpleDateFormat,java.sql.*"%>
<%@ page import="java.security.Security" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Web聊天 - 消息发送窗口</title>
	<style>
		/* 保持现有的CSS样式不变 */
		body {
			font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
			background-color: #f0f2f5;
			color: #333;
			display: flex;
			justify-content: center;
			align-items: center;
			height: 100vh;
			margin: 0;
		}
		#prevPageBtn,
		#nextPageBtn {
			display: none;
		}
		.chat-container {
			background-color: white;
			border-radius: 12px;
			box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
			padding: 30px;
			width: 650px;
			position: relative;
			overflow: visible; /* 确保表情面板不会被裁剪 */
		}

		.welcome-header {
			text-align: center;
			color: #2c3e50;
			margin-bottom: 20px;
			font-weight:600;
			font-size:24px;
		}

		.message-container {
			display: flex;
			align-items: center;
			gap: 10px;
			margin-bottom: 15px;
		}

		.message-type-radio {
			display: flex;
			align-items: center;
			gap: 10px;
		}

		.message-type-radio label {
			cursor: pointer;
			display: flex;
			align-items: center;
			gap: 5px;
			font-weight:500;
		}

		.input-row {
			display: flex;
			align-items: center;
			gap: 10px;
			position: relative;
		}

		.message-input {
			flex: 1;
			padding: 10px;
			border: 1px solid #ddd;
			border-radius: 6px;
			transition: border-color 0.3s ease;
			font-size:14px;
		}

		.message-input:focus {
			outline: none;
			border-color: #3498db;
		}

		.toolbar {
			display: flex;
			align-items: center;
			gap: 10px;
		}

		.toolbar-button {
			width: 32px;
			height: 32px;
			border: none;
			cursor: pointer;
			border-radius: 50%;
			background-color: #fff;
			background-position: center;
			background-repeat: no-repeat;
			background-size: 60%;
			transition: background-color 0.3s;
			position: relative;
		}
		.toolbar-button:hover {
			background-color:#ecf0f1;
		}
		.toolbar-button:hover::after {
			content: attr(data-title);
			position: absolute;
			bottom: 40px;
			background: rgba(0,0,0,0.7);
			color: #fff;
			font-size:12px;
			padding:4px 8px;
			border-radius:4px;
			white-space: nowrap;
			left:50%;
			transform:translateX(-50%);
		}

		/* 表情按钮 */
		.emoji-button {
			background-image: url('image/emoji.png');
		}

		/* 上传文件按钮 */
		.upload-button {
			background-image: url('image/upload.png');
		}

		/* 历史记录按钮 */
		.history-button {
			background-image: url('image/HistoricalRecord.png');
		}
		/* AI对话按钮 */
		.ai-button {
			background-image: url('image/AI.png');
		}
		.emoji-panel {
			position: absolute;
			bottom: 50px;
			right: 0px; /* 与emoji按钮对齐右侧 */
			background: #fff;
			border: 1px solid #ddd;
			border-radius: 8px;
			padding: 10px;
			display: none;
			box-shadow: 0 2px 10px rgba(0,0,0,0.1);
			max-width:250px;
			max-height:260px;
			display:flex;
			flex-direction:column;
			z-index:9999;
		}

		.emoji-grid {
			display:flex;
			flex-wrap:wrap;
			max-width:230px;
			overflow:auto;
		}

		.emoji-grid span {
			cursor: pointer;
			font-size: 20px;
			margin: 5px;
			transition: transform 0.1s ease;
			display: inline-block;
		}

		.emoji-grid span:hover {
			transform: scale(1.2);
		}

		.emoji-pagination {
			display:flex;
			justify-content: space-between;
			margin-top:10px;
		}

		.emoji-pagination button {
			background:#3498db;
			color:#fff;
			border:none;
			padding:4px 8px;
			border-radius:4px;
			cursor:pointer;
			font-size:12px;
		}

		.emoji-pagination button:disabled {
			background:#bdc3c7;
			cursor:not-allowed;
		}

		.private-recipient-select {
			width: 100%;
			padding: 10px;
			border: 1px solid #ddd;
			border-radius: 6px;
			margin-bottom: 15px;
			display: none;
			font-size:14px;
		}

		.button-container {
			display: flex;
			justify-content: center;
			gap: 20px;
			margin-top: 20px;
		}

		.submit-button, .logout-button {
			width: 150px;
			padding: 12px 20px;
			border: none;
			border-radius: 8px;
			font-size: 16px;
			cursor: pointer;
			transition: background-color 0.3s ease, transform 0.1s ease;
			font-weight:500;
		}

		.submit-button {
			background-color: #3498db;
			color: white;
		}

		.submit-button:hover {
			background-color: #2980b9;
			transform: scale(1.05);
		}

		.logout-button {
			background-color: #e74c3c;
			color: white;
		}

		.logout-button:hover {
			background-color: #c0392b;
			transform: scale(1.05);
		}

		p.status-message {
			margin-top:10px;
			font-weight:500;
		}

		p.status-message.success {
			color:green;
		}
		p.status-message.error {
			color:red;
		}
		/* 弹出输入框 */
		.ai-input-container {
			display: none;
			position: fixed;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			background-color: white;
			padding: 20px;
			border-radius: 10px;
			box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
			width: 450px; /* 调整输入框宽度 */
			max-width: 90%;
			z-index: 10000;
		}

		.ai-input-container input {
			width: 100%;
			padding: 15px; /* 增加输入框内边距，让输入区域更大 */
			font-size: 18px; /* 增加字体大小 */
			margin-bottom: 15px;
			border: 1px solid #ddd;
			border-radius: 6px;
			box-sizing: border-box; /* 确保padding不会影响总宽度 */
		}

		.ai-input-container .button-container {
			display: flex;
			gap: 10px; /* 设置按钮之间的间距 */
		}

		.ai-input-container button {
			width: 48%; /* 按钮宽度设置为父容器的48%，确保它们并排 */
			padding: 10px;
			background-color: #3498db;
			color: white;
			border: none;
			border-radius: 6px;
			cursor: pointer;
			font-size: 14px; /* 调整按钮字体 */
		}

		.ai-input-container button:hover {
			background-color: #2980b9;
		}

		/* Upload success icon */
		.upload-success-icon {
			width: 16px;
			height: 16px;
			margin-left: 5px;
			vertical-align: middle;
		}
			 /* 调整取消按钮的样式 */
		 #cancelFileButton:hover {
			 background-color: #c0392b;
			 transform: scale(1.05); /* 鼠标悬停时轻微放大 */
			 box-shadow: 0 6px 15px rgba(192, 57, 43, 0.4); /* 增加阴影 */
		 }

		#cancelFileButton:active {
			transform: scale(0.95); /* 点击时缩小 */
			box-shadow: 0 2px 5px rgba(192, 57, 43, 0.6); /* 调整阴影 */
		}

		/* 输入框的样式 */
		#fileNameInput {
			padding: 8px;
			border: 1px solid #ddd;
			border-radius: 6px;
			font-size: 14px;
			box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
			flex: 1;
		}

		/* 预览容器样式 */
		#filePreview {
			margin-top: 10px;
			display: flex;
			align-items: center;
			gap: 10px;
		}
		#modelSelect {
			width: 100%;
			padding: 10px;
			margin-bottom: 15px;
			border: 1px solid #ddd;
			border-radius: 6px;
			font-size: 14px;
		}
	</style>
	<script src="https://cdn.jsdelivr.net/npm/openai@4.29.2/dist/index.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
	<script>
		// AI对话多模型功能逻辑
		const AI_MODELS = {
			// 通义千问模型
			'qwen-plus': {
				name: 'qwen-plus',
				type: 'qwen',
				endpoint: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
				apiKey: ''
			},
			'qwen-turbo': {
				name: 'qwen-coder-turbo-latest',
				type: 'qwen',
				endpoint: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
				apiKey: ''
			},
			'qwen-max': {
				name: 'qwen-coder-turbo-0919',
				type: 'qwen',
				endpoint: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
				apiKey: ''
			},

			'gpt-4o-mini': {
				name: 'gpt-4o-mini',
				type: 'openai'
			}
		};

		function openAIInput() {
			// 动态生成模型选择选项
			const modelSelect = document.getElementById('modelSelect');
			modelSelect.innerHTML = '<option value="">选择AI模型</option>';

			Object.keys(AI_MODELS).forEach(modelKey => {
				const option = document.createElement('option');
				option.value = modelKey;
				option.textContent = AI_MODELS[modelKey].name;
				modelSelect.appendChild(option);
			});

			document.getElementById('aiInputContainer').style.display = 'block';
		}

		function closeAIInput() {
			document.getElementById('aiInputContainer').style.display = 'none';
		}

		async function generateAIResponse() {
			const userInput = document.getElementById('aiUserInput').value;
			const selectedModelKey = document.getElementById('modelSelect').value;

			if (userInput.trim() === "") {
				alert('请输入问题');
				return;
			}

			if (!selectedModelKey) {
				alert('请选择AI模型');
				return;
			}

			const model = AI_MODELS[selectedModelKey];

			try {
				if (model.type === 'qwen') {
					// 通义千问模型调用
					const requestBody = {
						model: selectedModelKey,
						messages: [
							{ role: "system", content: "你是一个有帮助的助手。" },
							{ role: "user", content: userInput }
						]
					};

					const response = await fetch(model.endpoint, {
						method: 'POST',
						headers: {
							'Content-Type': 'application/json; charset=utf-8',
							'Authorization': 'Bearer'
						},
						body: JSON.stringify(requestBody)
					});

					// 处理API响应
					if (response.ok) {
						const data = await response.json();
						const aiResponse = data.choices[0].message.content;

						// 将AI回答填入聊天输入框
						document.getElementById('message').value = aiResponse;
						closeAIInput();
					} else {
						const errorData = await response.text();
						throw new Error(`通义千问API调用失败：${errorData}`);
					}
				} else if (model.type === 'openai') {
					// 修改后的OpenAI模型调用

					const requestBody = {
						model: selectedModelKey,  // 使用 gpt-4o-mini 模型
						messages: [
							{ role: "system", content: "You are a helpful assistant." },  // system角色的内容
							{ role: "user", content: userInput }  // 用户输入的内容
						],
						temperature: 0.7
					};

					// 发送请求并处理静态响应
					const response = await fetch('https://api.openai.com/v1/chat/completions', {
						method: 'POST',
						headers: {
							'Content-Type': 'application/json',
							'Authorization': ''// 请替换为你的API密钥
						},
						body: JSON.stringify(requestBody)
					});

					if (response.ok) {
						const data = await response.json();
						const aiResponse = data.choices[0].message.content;

						// 将AI回答填入聊天输入框
						document.getElementById('message').value = aiResponse;
						closeAIInput();
					} else {
						throw new Error('API调用失败');
					}
				} else {
					// 处理未知模型类型
					throw new Error(`不支持的模型类型：${model.type}`);
				}
			} catch (error) {
				console.error('AI响应生成错误', error);
				alert(`发生错误：${error.message}`);
			}
		}

	</script>
	<script>
		// 表情功能逻辑
		var currentPage = 0;
		var pageSize = 21;

		var allEmojis = [
			'😊', '😂', '😍', '👍', '😢', '😡', '🎉', '😏', '🤔', '🙄', '😴', '😱', '😆', '😇', '😘', '😜', '🙈', '🙉', '🙊', '❤️', '💔', '✨', '🔥', '⚡', '⭐', '💦', '💤', '👀', '👋', '👏', '👐', '✌', '🤞', '🤙', '👌', '👈', '👉', '👆', '👇', '👎', '🖐', '👊', '🤝', '🙏', '💪', '💃', '🕺', '💅', '👑', '💄', '🎂', '🍰', '🍕', '🍎', '🍔', '🍟', '🍣', '🍱', '🍩', '☕', '🍵', '🍺', '🍻', '🍷', '⚽', '🏀', '🏆', '🎮', '🎧', '💻', '📱', '🗑', '📢', '📬', '🕰', '⏰', '🚀', '🛫', '🎁', '🛒', '💡', '🔑', '🚦', '🚗', '🚌', '🚲', '🎲'
		];

		function showEmojiPage(page) {
			var grid = document.getElementById('emojiGrid');
			grid.innerHTML = '';

			var start = page * pageSize;
			var end = start + pageSize;
			var pageEmojis = allEmojis.slice(start, end);

			pageEmojis.forEach(function (e) {
				var span = document.createElement('span');
				span.textContent = e;
				span.onclick = function () { insertEmoji(e) };
				grid.appendChild(span);
			});

			// 根据当前页数判断是否需要显示上一页和下一页按钮
			var shouldShowPrev = (page > 0);
			var shouldShowNext = (end < allEmojis.length);
			updatePaginationButtonsVisibility(shouldShowPrev, shouldShowNext);
		}

		function updatePaginationButtonsVisibility(showPrev, showNext) {
			var prevPageBtn = document.getElementById('prevPageBtn');
			var nextPageBtn = document.getElementById('nextPageBtn');
			if (showPrev) {
				prevPageBtn.style.display = 'inline-block';
			} else {
				prevPageBtn.style.display = 'none';
			}
			if (showNext) {
				nextPageBtn.style.display = 'inline-block';
			} else {
				nextPageBtn.style.display = 'none';
			}
		}

		function prevEmojiPage() {
			if (currentPage > 0) {
				currentPage--;
				showEmojiPage(currentPage);
			}
		}

		function nextEmojiPage() {
			var maxPage = Math.ceil(allEmojis.length / pageSize) - 1;
			if (currentPage < maxPage) {
				currentPage++;
				showEmojiPage(currentPage);
			}
		}

		function togglePrivateRecipient() {
			var privateRadio = document.getElementById('privateRadio');
			var privateRecipientSelect = document.getElementById('privateRecipient');
			privateRecipientSelect.style.display = privateRadio.checked? 'block' : 'none';
		}

		function validateForm() {
			var privateRadio = document.getElementById('privateRadio');
			var privateRecipientSelect = document.getElementById('privateRecipient');
			var messageInput = document.getElementById('message');
			var fileInput = document.getElementById('fileInput');

			if (privateRadio.checked && privateRecipientSelect.value === '') {
				alert('请选择你要单独发送的对象！');
				return false;
			}

			if (messageInput.value.trim() === '' && fileInput.files.length === 0) {
				alert('消息或文件必须至少输入一个！');
				return false;
			}

			return true;
		}

		function openHistoryRecord() {
			window.open('WebChat_HistoryRecord.jsp', 'HistoryRecord',
					'width=600, height=500, resizable=yes, scrollbars=yes, top=200, left=300');
		}

		function toggleEmojiPanel() {
			var panel = document.getElementById('emojiPanel');
			if (panel.style.display ==='block') {
				panel.style.display = 'none';
			} else {
				panel.style.display = 'block';
				currentPage = 0;
				showEmojiPage(currentPage);
			}
		}

		function insertEmoji(emoji) {
			var messageInput = document.getElementById('message');
			messageInput.value += emoji;
			var panel = document.getElementById('emojiPanel');
			panel.style.display = 'none';
			messageInput.focus();
		}
	</script>
	<script>
		var contextPath = '<%= request.getContextPath() %>';
	</script>
	<script>
		let selectedFile = null;

		window.onload = function () {
			document.getElementById('filePreview').style.display = 'none';
		};

		function handleFileSelect(event) {
			const fileInput = event.target;
			const file = fileInput.files[0];
			const fileNameInput = document.getElementById('fileNameInput');
			const filePreview = document.getElementById('filePreview');

			const allowedFileTypes = [
				'image/png', 'image/jpeg', 'application/pdf', 'application/msword',
				'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
				'text/csv', 'text/plain', 'application/x-python-code', 'application/vnd.ms-powerpoint',
				'application/vnd.openxmlformats-officedocument.presentationml.presentation',
				'application/zip', 'application/x-rar-compressed', 'image/gif', 'video/mp4'
			];

			if (file) {
				if (!allowedFileTypes.includes(file.type)) {
					alert('不支持的文件类型，请选择正确的文件格式。');
					clearFileSelection();
					return;
				}

				if (file.size > 60 * 1024 * 1024) {
					alert('文件大小不能超过60MB。');
					clearFileSelection();
					return;
				}

				selectedFile = file;
				fileNameInput.value = file.name;
				filePreview.style.display = 'flex';

				const contextPath = '<%= request.getContextPath() %>';
				displayStatusMessage("文件上传成功 <img src='" + contextPath + "/image/success.png' alt='Success' class='upload-success-icon'>", "success");
			} else {
				clearFileSelection();
			}
		}

		function clearFileSelection() {
			const fileInput = document.getElementById('fileInput');
			const filePreview = document.getElementById('filePreview');
			const fileNameInput = document.getElementById('fileNameInput');

			fileInput.value = '';
			fileNameInput.value = '';
			filePreview.style.display = 'none';
			selectedFile = null;
		}

		function displayStatusMessage(message, type) {
			const statusDiv = document.getElementById('status');
			statusDiv.innerHTML = "<p class='status-message " + type + "'>" + message + "</p>";
		}

		function validateForm() {
			const messageInput = document.getElementById('message');
			const privateRecipient = document.getElementById('privateRecipient');

			if (privateRecipient.value === '' && messageInput.value.trim() === '' && !selectedFile) {
				alert('消息或文件必须至少填写一项。');
				return false;
			}

			return true;
		}
	</script>

</head>
<body>
<div class="chat-container">
	<h2 class="welcome-header">欢迎，<%=session.getAttribute("user")%>！</h2>
	<%
		// Retrieve status message from request attributes
		String statusMessage = (String) request.getAttribute("statusMessage");
		String statusClass = (String) request.getAttribute("statusClass");
	%>
	<form id="messageForm" action="FileUploadServlet" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
		<div class="message-container">
			<div class="message-type-radio">
				<label>
					<input type="radio" name="messageType" value="group" checked onclick="togglePrivateRecipient()">
					群发
				</label>
				<label>
					<input type="radio" name="messageType" id="privateRadio" value="private" onclick="togglePrivateRecipient()">
					私发
				</label>
			</div>
		</div>

		<div class="input-row">
			<input type="text" class="message-input" name="message" id="message" placeholder="输入您的消息">
			<div class="toolbar">
				<button type="button" class="toolbar-button emoji-button" data-title="Emoji表情包" onclick="toggleEmojiPanel()"></button>
				<button type="button" class="toolbar-button upload-button" data-title="上传文件" onclick="document.getElementById('fileInput').click();"></button>
				<button type="button" class="toolbar-button history-button" data-title="查看历史记录" onclick="openHistoryRecord()"></button>
				<!-- AI对话按钮 -->
				<button type="button" class="toolbar-button ai-button" data-title="AI对话" onclick="openAIInput()"></button>
			</div>
			<div class="emoji-panel" id="emojiPanel">
				<div class="emoji-grid" id="emojiGrid"></div>
				<div class="emoji-pagination">
					<button type="button" id="prevPageBtn" onclick="prevEmojiPage()">上一页</button>
					<button type="button" id="nextPageBtn" onclick="nextEmojiPage()">下一页</button>
				</div>
			</div>
		</div>
		<!-- 隐藏的文件选择框 -->
		<input type="file" name="uploadedFile" id="fileInput" style="display: none;" onchange="handleFileSelect(event)">

		<!-- 文件预览容器 -->
		<div id="filePreview" style="display: none; margin-top: 10px; display: flex; align-items: center; gap: 10px;">
			<input type="text" id="fileNameInput" readonly placeholder="文件名称" style="flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);">
			<button type="button" id="cancelFileButton" onclick="clearFileSelection()" style="padding: 10px 20px; border: none; background-color: #e74c3c; color: white; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 14px; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); transition: all 0.3s ease;">
				取消
			</button>
		</div>


		<!-- AI输入框 -->
		<div id="aiInputContainer" class="ai-input-container">
			<select id="modelSelect">
				<!-- 模型选项将动态生成 -->
			</select>
			<input type="text" id="aiUserInput" placeholder="请输入您的问题">
			<div class="button-container">
				<button type="button" onclick="generateAIResponse()">生成回答</button>
				<button type="button" onclick="closeAIInput()">取消</button>
			</div>
		</div>
		<select id="privateRecipient" name="privateRecipient" class="private-recipient-select">
			<option value="">选择私发对象</option>
			<%
				Connection conn = null;
				try {
					Security.setProperty("jdk.tls.disabledAlgorithms", "");
					System.setProperty("https.protocols", "TLSv1");
					Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
					conn = DriverManager.getConnection(
							"jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
									"encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
									"disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
							"sa", "123456");

					String currentUser = (String) session.getAttribute("user");
					String query = "SELECT username FROM webChat.dbo.Login WHERE username != ?";
					PreparedStatement stmt = conn.prepareStatement(query);
					stmt.setString(1, currentUser);
					ResultSet rs = stmt.executeQuery();
					while (rs.next()) {
						String username = rs.getString("username");
			%>
			<option value="<%= username %>"><%= username %></option>
			<%
					}
					rs.close();
					stmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					if (conn != null) {
						try {
							conn.close();
						} catch (SQLException e) {
							e.printStackTrace();
						}
					}
				}
			%>
		</select>

		<div class="button-container">
			<button type="submit" class="submit-button">发送</button>
			<button type="button" class="logout-button" onClick="parent.location.href='WebChat_Logout.jsp'">退出</button>
		</div>
	</form>
	<% if (statusMessage != null && statusClass != null) { %>
	<p class="status-message <%=statusClass%>"><%=statusMessage%></p>
	<% } %>
	<!-- 用于AJAX上传文件后的状态消息 -->
	<div id="status"></div>
</div>
</body>
</html>
