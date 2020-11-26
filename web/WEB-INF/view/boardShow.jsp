<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>
<%@ page import="board.BoardDTO" %>

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
	
	String boardID = null;
	if(request.getParameter("boardID") != null) {
		boardID = (String) request.getParameter("boardID");
	}
	
	if(boardID == null || boardID.equals("")) {
		session.setAttribute("messageType", "오류메시지");
		session.setAttribute("messageContent","게시물을 선택해주세요.");
		response.sendRedirect("index.jsp");
		return;
	}
	
	BoardDAO boardDAO = new BoardDAO();
	BoardDTO board = boardDAO.getBoard(boardID);
	if(board.getBoardAvailable() == 0) {
		session.setAttribute("messageType", "오류메시지");
		session.setAttribute("messageContent","삭제된 게시물입니다.");
		response.sendRedirect("boardView.jsp");
		return;
	}
	
	boardDAO.hit(boardID);
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
				<li><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li>
				<li class="active"><a href="boardView.jsp">자유게시판</a></li>
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
		<table class="table table-bordered table-hover"
			style="text-align: center; border: 1px solid #dddddd">
			<thead>
				<tr>
					<th colspan="4"><h4>게시물 보기</h4></th>
				</tr>
				<tr>
					<td style="background-color: #fafafa; color: #000000; width: 80px;"><h5>제목</h5></td>
					<td colspan="3"><h5><%= board.getBoardTitle() %></h5></td>
				</tr>
				<tr>
					<td style="background-color: #fafafa; color: #000000; width: 80px;"><h5>작성자</h5></td>
					<td colspan="3"><h5><%= board.getUserID() %></h5></td>
				</tr>
				
			    <tr>
					<td style="background-color: #fafafa; color: #000000; width: 80px;"><h5>작성 날짜</h5></td>
					<td><h5><%= board.getBoardDate() %></h5></td>
					<td style="background-color: #fafafa; color: #000000; width: 80px;"><h5>조회수</h5></td>
					<td><h5><%= board.getBoardHit() + 1 %></h5></td>
				</tr>
				
				<tr>
					<td style="vertical-align: middle; min-height: 150px; background-color: #fafafa; color: #000000; width: 80px;"><h5>글 내용</h5></td>
					<td colspan="3" style="text-align: left;"><h5><%= board.getBoardContent() %></h5></td>
				</tr>
				
				<tr>
					<td style="background-color: #fafafa; color: #000000; width: 80px;"><h5>첨부파일</h5></td>
					<td colspan="3"><h5> <a href="boardDownload.jsp?boardID=<%= board.getBoardID() %>"> <%= board.getBoardFile() %></a></h5></td>
				</tr>

				
			</thead>
			<tbody>
				<tr>
					
					<td colspan="5" style="text-align: right;">
					
					
					<a href="boardView.jsp" class="btn btn-primary">목록</a>
					<a href="boardReply.jsp?boardID=<%= board.getBoardID() %>" class="btn btn-primary">답변</a>
					<%
						if(userID.equals(board.getUserID())) {
					%>
						<a href="boardUpdate.jsp?boardID=<%= board.getBoardID() %>" class="btn btn-primary" type="submit">수정</a>
						<a href="BoardDeleteServlet?boardID=<%= board.getBoardID() %>" class="btn btn-primary" onclick="return confirm('정말로 삭제하시겠습니까?');">삭제</a>
					<%
						}
					%>
					</td>
				
				</tr>
			</tbody>
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
		});
		</script>
	<%
		}
	%>
	
	
</body>
</html>