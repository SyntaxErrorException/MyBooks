<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="ja">

<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MyBooks</title>
<link rel="stylesheet"
	href="<%= request.getContextPath() %>/css/bootstrap.min.css" />
<link rel="stylesheet"
	href="<%= request.getContextPath() %>/css/style.css" />
</head>

<body>
	<h1>Book List</h1>
	<p>
		ISBN: <input type="text" id="isbnCode">
		現在のページ: <input type="number" id="currentPage" min="0" value="0">
		<button id="btn">追加</button>
	</p>

	<!-- テーブルをc:forEachで記述する -->
	<table id="book-table">
		<c:forEach items="${bookList}" var="book" varStatus="vs">
			<tr style="height: 20px;">
				<td id="cover" rowspan="2">
					<!-- 表紙 -->
					<img src="<c:out value="${book.cover}" />" alt="BookCover" />
				</td>
				<td id="title">
					<!-- タイトル --> <c:out value="${book.title}" />
				</td>
				<td id="authors">
					<!-- 著者 --> <c:out value="${book.authors}" />
				</td>
				<td id="pageCount">
					<!-- ページ数 --> <c:out value="${book.pageCount}" />
				</td>
				<td>
					<!-- ブックマーク -->
					<input type="number" id="bookmark" min="0"
					value="<c:out value="${book.bookmark}" />">
					<button id="update" onclick="update(<c:out value="${book.id += ','}"/>$(this).prev().val())">更新</button></td>
				<td id="progress">
					<!-- 進捗 --> 進捗:<fmt:formatNumber
						value="${book.bookmark / book.pageCount * 100}" pattern="##0" />%
				</td>
				<td>
					<!-- 読了 -->
					<button id="finished" onclick="finished(<c:out value="${book.id}"/>)">読了</button>
				</td>
			</tr>
			<tr>
				<td id="description" colspan="6">
					<!-- 概要 --> <c:out value="${book.description}" />
				</td>
			</tr>
		</c:forEach>
	</table>

	<!-- テーブル行のテンプレート -->
	<template id="book-row-template">
		<tr style="height: 20px;">
			<td id="cover" rowspan="2">
				<!-- 表紙 -->
			</td>
			<td id="title">
				<!-- タイトル -->
			</td>
			<td id="authors">
				<!-- 著者 -->
			</td>
			<td id="pageCount">
				<!-- ページ数 -->
			</td>
			<td>
				<!-- ブックマーク -->
				<input type="number" id="bookmark" min="0">
				<button id="update" onclick="update(<c:out value="${book.id}"/>)">更新</button></td>
			<td id="progress">
				<!-- 進捗 -->
			</td>
			<td>
				<!-- 読了 -->
				<button id="finished" onclick="finished(<c:out value="${book.id}"/>)">読了</button>
			</td>
		</tr>
		<tr>
			<td id="description" colspan="6">
				<!-- 概要 -->
			</td>
		</tr>
	</template>

	<script src="<%= request.getContextPath() %>/js/jquery-3.6.0.min.js"></script>
	<script>
	// 読了ボタンクリックで実行
	function finished(id){
        $(this).parent().parent().next().remove();
        $(this).parent().parent().remove();
        
        //レコード削除のサーブレットへ誘導
        window.location.href = '/MyBooks/members/finished?id=' + id;
	}
	
	// 更新ボタンクリックで実行
	function update(id,num){
		//レコード更新のサーブレットへ誘導
		window.location.href = '/MyBooks/members/update?id=' + id + '&page=' + num;
	}
	
    /**
     * Book List テーブルの1冊分を生成する関数
     * @param プロパティとしてtitle,authors,pageCount,discription,smallTumbnailを持つ
     * @return 本のデータが入ったtr要素
     */
                function createRow(book) {
                    // テンプレートの要素(1冊分のHTML)を複製
                    const clone = $($('#book-row-template').html());
                    
                    /**
                    *表紙用の変数にサムネイルを格納
                    *古い本の場合、プロパティが存在しないのでtry-catchで囲む
                    */
                    try {
                        clone.find('#cover').append('<img src=\"' + book.items[0]
                            .volumeInfo.imageLinks.smallThumbnail + '\" />');
                    } catch {
                    	clone.find('#cover').append('');
                    }
                    
                    //共著の場合に対応するための処理
                    let authorsList = '';
                    if (book.items[0].volumeInfo.authors.length > 1) {
                    	book.items[0].volumeInfo.authors.forEach(e => authorsList += e + '・');
                    	authorsList = authorsList.replace(/・$/,"");
                    } else {
                        authorsList = book.items[0].volumeInfo.authors[0];
                    }
                    
                    // td要素にデータを追加
                    clone.find('#title').append(book.items[0].volumeInfo.title);
                    clone.find('#authors').append(authorsList);
                    clone.find('#pageCount').append(book.items[0].volumeInfo.pageCount);
                    clone.find('#progress').append('進捗:' +
                        Math.round($('#currentPage').val() / book.items[0].volumeInfo.pageCount * 100) + '%');
                    clone.find('#description').append(book.items[0].volumeInfo.description);
                    clone.find('#bookmark').val($('#currentPage').val());

                    // 読了した本を削除
                    clone.find('#finished').click(function () {
                        $(this).parent().parent().next().remove();
                        $(this).parent().parent().remove();
                        window.location.href = '/MyBooks/members/finished?id=' + id;
                    });

                    // 進捗を更新
                    clone.find('#update').click(function () {
                        $(this).parent().next().text(
                            '進捗:' + Math.round($(this).prev().val() / $(this).parent().prev().text() * 100) + '%');
                    });
                    
                    
                    return clone;
                }
                
                // メインの処理
                $(document).ready(function () {
                    $('#btn').click(function () {
                        const isbnCode = $('#isbnCode').val();
                        const endpoint = 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + isbnCode;
                        $.ajax({
                            url: endpoint,
                            type: 'GET',
                            dateType: JSON
                        })// ajax
                            .done(function (res) {
                                // 取得したデータの確認
                                console.log(res);

                                if (res.totalItems == 1) {
                                    // テーブルに行を追加
                                    $('#book-table').prepend(createRow(res));

                                    /*
                                    表紙用の変数にサムネイルを格納
                                    古い本の場合、プロパティが存在しないのでtry-catchで囲む
                                    */
                                    let cover = '';
                                    try {
                                    	cover = res.items[0].volumeInfo.imageLinks.smallThumbnail;
                                    } catch {
                                    	cover = 'No image';
                                    }

                                    //共著の場合に対応するための処理
                                    let authorsList = '';
                                    if (res.items[0].volumeInfo.authors.length > 1) {
                                    	res.items[0].volumeInfo.authors.forEach(e => authorsList += e + '・');
                                    	authorsList = authorsList.replace(/・$/,"");
                                    } else {
                                        authorsList = res.items[0].volumeInfo.authors[0];
                                    }

                                    //JSONからJavaScriptオブジェクトへ変換
                                    const data = {
                                    	title: res.items[0].volumeInfo.title,
                                    	authors: authorsList,
                                    	pageCount: res.items[0].volumeInfo.pageCount,
                                    	description: res.items[0].volumeInfo.description,
                                    	isbn: isbnCode,
                                    	bookmark: $('#currentPage').val(),
                                    	cover: cover
                                    };
                                    
                                    sendToServlet(data);
                                } else {
                                    alert('totalItems:' + res.totalItems + '\r\n検索結果が複数のため追加できません。');
                                }
                            })//done
                            .fail(function () {
                                $('#inputISBN').after('<p>データの取得に失敗しました。</p>')
                            });//fail
                    });//click
                });//ready
                    
                function sendToServlet(dataToSend){
                   	  $.ajax({
	                     url: 'http://localhost:8080/MyBooks/members/showBookList',
	                     type: 'POST',
	                     data: dataToSend
	                  })//ajax
	                 .done(function(res){
	                	  console.log("成功");
	                  })//done                    	
	                  .fail(function(){
	                	  console.log("失敗");
	                  });//fail
                }
	</script>
</body>
</html>