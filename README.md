# ShenDaChatroom 项目

## **项目简介**
ShenDaChatroom 是一款功能齐全的在线聊天室，集成多种现代化功能，结合大语言模型与文明聊天环境维护，致力于提供安全、智能、个性化的聊天体验。

---

## **功能特点**
1. **用户注册与登录**：
   - 严格的注册信息校验，省市区三级联动选择。
   - 登录界面动态美化，密码错误尝试限制。

2. **聊天功能**：
   - 公聊与私聊分离，支持表情包发送。
   - 聊天记录查看与导出，支持TXT、CSV、Excel格式。

3. **文明聊天维护**：
   - 屏蔽不文明用语，敏感词可提示或替换。

4. **文件传输**：
   - 支持多种文件格式上传、显示与下载。

5. **智能化支持**：
   - 集成ChatGPT、通义千问等5种语言模型，智能辅助聊天。

6. **管理员管理**：
   - 动态维护屏蔽词库。
   - 查看与管理用户信息和聊天记录。

7. **系统美化与发布**：
   - 页面设计美观，参考主流社交软件。
   - 通过动态域名与反向代理，实现外网访问。

---

## **技术栈**
- **前端**：HTML5, CSS3, JavaScript
- **后端**：Java (JSP/Servlet), MySQL
- **智能模型**：ChatGPT, 通义千问 API 接入
- **部署工具**：Nginx, 动态域名绑定, 内网穿透

---

## **安装与使用**
### **环境要求**
- JDK 11+
- MySQL 8.0+
- Maven 3.6+
- Nginx

### **安装步骤**
1. 克隆代码仓库：
   ```bash
   git clone https://github.com/Auroral0810/ShenDaChatroom.git
   cd ShenDaChatroom
