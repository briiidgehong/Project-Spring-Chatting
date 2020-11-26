<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html> <!--html5를 따른다. -->
<html>
<%
	String userID = null; //세션관리
	if (session.getAttribute("userID") != null) { // 세션값이 존재하지 않는다면
		userID = (String) session.getAttribute("userID"); // 가져와라
	}
	
	if(userID == null) {
		session.setAttribute("messageType", "오류메시지");
		session.setAttribute("messageContent","현재 로그인이 되어 있지 않습니다.");
		response.sendRedirect("index.jsp");
		return;
	}
%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1"> <!-- 부트스트랩을 넣었을때 반응형 웹이 잘 출력될수 있도록 뷰포트를 넣어준다.  -->
	<link rel="stylesheet" href="css/bootstrap.css"> <!--css 파일 불러오기  -->
	<link rel="stylesheet" href="css/custom.css"> <!--css 파일 불러오기  -->
	
	<title>JSP Ajax 실시간 회원제 채팅 서비스</title>
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script> <!--ajax 를 위해서 공식사이트에서 제공하는 제이쿼리를 링크로 가져온다.  -->
	<script src="js/bootstrap.js"></script> <!--마찬가지로 우리가 받았던 부트스트랩 안의 js 페이지도 가져온다. -->
	<script type="text/javascript">
		function getUnread() {
			$.ajax({
				type: "POST",
				url: "./ChatUnreadServlet",
				data: {
					userID: encodeURIComponent('<%= userID %>'),
				},
				success: function(result){
					if(result >=1){
						showUnread(result);
					}else{
						showUnread('');
					}
				}
			});
			
		}
		
		function getInfiniteUnread() {
			setInterval(function() {
				getUnread();
			}, 2000);
		}
		function showUnread(result) {
			$('#unread').html(result);
		}
		
		function chatBoxFunction() {
			var userID = '<%= userID %>';
			$.ajax({
				type: "POST",
				url: "./ChatBoxServlet",
				data: {
					userID: encodeURIComponent(userID),
				},
				success: function(data){
					if(data == "") return;
					$('#boxTable').html('');
					var parsed = JSON.parse(data);
					var result = parsed.result;
					for(var i=0; i< result.length; i++){
						if(result[i][0].value == userID) {
							result[i][0].value = result[i][1].value;
						}else {
							result[i][1].value = result[i][0].value;
						}
						addBox(result[i][0].value, result[i][1].value, result[i][2].value, result[i][3].value, result[i][4].value, result[i][5].value);
					}
				}
			});
			
		}
		
		function addBox(lastID, toID, chatContent, chatTime, unread, profile) {
			$('#boxTable').append('<tr onclick="location.href=\'chat.jsp?toID=' + encodeURIComponent(toID) +'\'">' +
					'<td style="width: 150px;"><h5>' +
					'<img class="media-object img-circle" style="margin: 0 auto; max-width: 40px; max-height: 40px;" src="' + profile +   '">' +
					'<h5>' + lastID + '</h5></td>' +
					'<td>' +
					'<h5>' + chatContent + '&nbsp;&nbsp;&nbsp;' +
					'<span class="label label-info">'  + unread + '</span>' + '</h5>' +
					'<div class="pull-right">' + chatTime + '</div>' +
					'</td>' +
					'</tr>');
		}
		function getInfiniteBox() {
			setInterval(function() {
				chatBoxFunction();
			}, 3000);
		}
	</script>
	
</head>
<body>
	<nav class="navbar navbar-default"> <!-- 디폴트로 부트스트랩의 네브바 컴포넌트를 사용한다.   -->
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
					<span class="icon-bar"></span> <!-- 가로 막대기 -->
					<span class="icon-bar"></span>	
					<span class="icon-bar"></span>	
					
				</button>
				<a class="navbar-brand" href="index.jsp"> 실시간 회원제 채팅 서비스 </a>
		</div>
		
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="index.jsp">메인</a></li>
				<li><a href="find.jsp">친구찾기</a></li>
				<li class="active"><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li>
				<li><a href="boardView.jsp">자유게시판</a></li>
			</ul>
			
			<%
				if(userID == null){
			%>
			
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">접속하기<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="login.jsp">로그인</a></li>
						<li><a href="join.jsp">회원가입</a></li>
					</ul>
					
				</li>
			</ul>
			
			<%
				} else {
			%>
			
		<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">회원관리<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="update.jsp">회원정보수정</a></li>
						<li><a href="profileUpdate.jsp">프로필 수정</a></li>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					</ul>
					
				</li>
			</ul>
			
			<%
				} 
			%>
		
			
		</div>
	</nav>
	
	<div class="container">
		<table class="table" style="margin: 0 auto;">
			<thead>
				<tr>
					<th><h4>주고받은 메시지 목록</h4></th>
				</tr>
			</thead>
			<div style="overflow-y: auto; width: 100%; max-height: 450px;">
				<table class="table table-bordered table-hover" style="text-align: center; border: 1px solid #dddddd; margin: 0 auto;">
					<tbody id="boxTable"> 
					</tbody>
				</table>
			</div>
		</table>
	</div>

	<!-- 모달창 생성 -->
	<% 
		String messageContent = null;
		if(session.getAttribute("messageContent") !=null) {
			messageContent = (String) session.getAttribute("messageContent");
		}
		
		String messageType = null;
		if(session.getAttribute("messageType") !=null) {
			messageType = (String) session.getAttribute("messageType");
		}

		if(messageContent != null) {
	%>	
	
	<div class="modal fade" id="messageModal" tabindex="-1" role="dialog" aria-hidden="true">
		<div class="vertical-alignment-helper">
			<div class="modal-dialog vertical-align-center">
					<div class="modal-content <% if(messageType.equals("오류메시지")) out.println("panel-warning"); else out.println("panel-success"); %>">
					<div class="modal-header panel-heading">
								<button type="button" class="close" data-dismiss="modal">
									<span aria-hidden="true">&times</span>
									<span class="sr-only">close</span>
								</button>
							
					<h4 class="modal-title">
							<%=messageType %>
					</h4>
					</div>
					<div class="modal-body">
						<%=messageContent %>
					</div>
					<div class="modal-footer">
							<button type="button" class="btn btn-primary" data-dismiss="modal">확인</button>
					</div>
			</div>
		</div>
	</div>
</div>				
	<script>
		$('#messageModal').modal("show");
	</script>

	
	
	<%
		session.removeAttribute("messageContent");
		session.removeAttribute("messageType");
		}
	%>		
	
	<%
		if(userID != null) {
	%>
		<script type="text/javascript">
		$(document).ready(function(){
			getUnread();
			getInfiniteUnread();
			chatBoxFunction();
			getInfiniteBox();
		});
		</script>
	<%
		}
	%>
	
	
	<div class="modal fade" id="checkModal" tabindex="-1" role="dialog" aria-hidden="true">
		<div class="vertical-alignment-helper">
			<div class="modal-dialog vertical-align-center">
					<div id="checkType" class="modal-content panel-info">
					<div class="modal-header panel-heading">
								<button type="button" class="close" data-dismiss="modal">
									<span aria-hidden="true">&times</span>
									<span class="sr-only">close</span>
								</button>
							
							<h4 class="modal-title">
								확인 메시지
							</h4>
					</div>
					<div id="checkMessage" class="modal-body">
					</div>
					<div class="modal-footer">
							<button type="button" class="btn btn-primary" data-dismiss="modal">확인</button>
					</div>
					
			</div>
		</div>
	</div>
</div>
</body>
</html>