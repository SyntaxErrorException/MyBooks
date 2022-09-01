<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="ja">

<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MyBooks</title>
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/bootstrap.min.css" />
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/style.css" />
<script src="<%=request.getContextPath()%>/js/jquery-3.6.0.min.js"></script>
</head>

<body>
	<h1>Book List</h1>
	<p>
		ISBN: <input type="number" id="isbnCode" autofocus> 現在のページ: <input
			type="number" id="currentPage" min="0" value="0">
		<button id="btn" type="button" class="btn btn-primary">追加</button>
		<button id="readingBooks" type="button" class="btn btn-info">現在進行中</button>
		<button id="allBooks" type="button" class="btn btn-info" style="display: none;">すべて表示</button>
	</p>

	<!-- テーブルをc:forEachで記述する -->
	<table id="bookTable" class="table table-striped">
		<thead>
			<tr class="headLine">
				<th>表紙</th>
				<th>タイトル</th>
				<th>著者</th>
				<th>ページ</th>
				<th>ブックマーク</th>
				<th>進捗</th>
				<th>読了</th>
			</tr>
		</thead>
			<c:forEach items="${bookList}" var="book" varStatus="vs">
			<tbody>
				<tr class="${'record' += vs.index} row1">
					<td class="cover" rowspan="2" style="width: 130px;"><c:set
							var="imgURL" value="<%=request.getContextPath()%>" /> <!-- 表紙 -->
						<img
						src="<c:out value="${empty book.cover? '../images/NoImage.png': book.cover}"/>"
						alt="BOOK COVER" /></td>
					<td class="title cell1">
						<!-- タイトル --> <c:out value="${book.title}" />
					</td>
					<td class="authors cell1">
						<!-- 著者 --> <c:out value="${book.authors}" />
					</td>
					<td class="pageCount cell1">
						<!-- ページ数 --> <c:out value="${book.pageCount}" />
					</td>
					<td>
						<!-- ブックマーク --> <input type="number" class="readingPage cell"
						min="0" value="<c:out value="${book.bookmark}" />">
						<button type="button" class="update btn btn-info"
							data-id="${book.id}">更新</button>
					</td>
					<td class="Progress cell1">
						<!-- 進捗 --> <fmt:formatNumber
							value="${book.bookmark / book.pageCount * 100}" pattern="##0.0" />
						%
					</td>
					<td>
						<!-- 読了 -->
						<button type="button" class="finished btn btn-warning"
							data-id="${book.id}">読了</button>
					</td>
				</tr>
				<tr class="${'record' += vs.index} row2">
					<td id="description${vs.index}" class="description" colspan="6">
						<!-- 概要 --> <c:out value="${book.description}" />
					</td>
					<td id="${vs.index}" class="registeredIsbn" style="display: none;"><c:out
							value="${book.isbn}" /></td>
				</tr>
			</tbody>
		</c:forEach>
	</table>

	<script>

	/*
	追加ボタン押下時の処理
	テーブルに一冊分のデータを追加する
	*/

	//重複登録の確認
   	//ISBNの重複があれば確認アラートを表示する

	$(document).ready(function () {
	    $('#btn').click(function () {
	    	// 登録済みISBNとの重複を調査する
	    	//「もう1冊、登録しますか？」に「いいえ」ならばリターン
        	const bool = duplication();
	    	if (bool){
		    	const result = confirm("登録済みのISBNです。\r\nもう１冊、登録しますか？");
		    	if (result === false) return;
	    	}

	    	//「はい」なら一冊分のデータを追加する
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
	
	                if (Number(res.totalItems) === 1) {
	                    /*
	                    表紙用の変数にサムネイルを格納
	                    古い本の場合、プロパティが存在しないのでtry-catchで囲む
	                    */
	                    let cover = null;
	                    try {
	                    	cover = res.items[0].volumeInfo.imageLinks.smallThumbnail;
	                    } catch(e) {
	                    	console.log(e);
	                    }
	
	                    //共著の著者名を連結
	                    //"・"を著者名の間に挟む
	                    //行末の"・"は削除
	                    let authorsList = '';
	                    if (res.items[0].volumeInfo.authors.length > 1) {
	                    	res.items[0].volumeInfo.authors.forEach(e => authorsList += e + '・');
	                    	authorsList = authorsList.replace(/・$/,'');
	                    } else {
	                        authorsList = res.items[0].volumeInfo.authors[0];
	                    }
	
	                    //JSONからJavaScriptオブジェクトへ変換
	                    const objJS = {
	                    	title: res.items[0].volumeInfo.title,
	                    	authors: authorsList,
	                    	pageCount: res.items[0].volumeInfo.pageCount,
	                    	description: res.items[0].volumeInfo.description,
	                    	isbn: isbnCode,
	                    	bookmark: $('#currentPage').val(),
	                    	cover: cover
	                    };
	                    
	                    // 入力フォームをクリア
	                    $('#isbnCode').val('');
	                    $('#currentPage').val('0');
	                    
	                    sendToBookList(objJS);
	                    
	                } else {
	                    alert('totalItems:' + res.totalItems + '\r\n検索結果が複数あります。入力を見直してください。');
	                }
	            })//done
	            .fail(function () {
	                $('#inputISBN').after('<p>データの取得に失敗しました。</p>')
	            });//fail
	    });//click
	    
	    //テーブルソート
		$('#bookTable').tablesorter({
			  headers: {
			      0: { sorter: "digit"},
			      1: { sorter: "digit"},
			      2: { sorter: "digit"},
			      3: { sorter: "digit"},
			      4: { sorter: "digit"},
			      5: { sorter: "text"}
				}
			});
	});//ready

	// 登録済みのISBNとの重複をチェックする
	function duplication(){
    	const registeredIsbn = document.getElementsByClassName('registeredIsbn');
    	if (registeredIsbn.length > 0) {
        	for (let isbn of registeredIsbn) {
            	if (isbn.textContent.trim() === $('#isbnCode').val()) {
                	return true;
            	}
        	}
        }
	}

    // ShowBookListサーブレットにJSONから変換したJSオブジェクトを送る    
    function sendToBookList(bookData){
      $.ajax({
      	url: 'http://localhost:8080/MyBooks/members/showBookList',
       type: 'POST',
       data: bookData
      })//ajax
      .done(function(res){
        window.location.reload();
        console.log("登録成功");
      })//done                    	
      .fail(function(){
        alert("登録失敗です。");
        console.log("登録失敗");
      });//fail
    }//sendToBookList

    //更新
    $('.update').click(function(){
          const update = {
           id: $(this).data('id'),
           page: $(this).prev().val(),
           pageCount: $(this).parent().prev().text().trim()
          }
		  const data = update.page / update.pageCount * 100;
		  //const digit = 1;
		  const progress = data.toFixed(1);
		  $(this).parent().next().text(progress + '%');
	      $.ajax({
	       url: 'http://localhost:8080/MyBooks/members/update',
	       type: 'GET',
	       data: update
	      })
	      .done(function(res){
	        console.log("更新成功");
	      })                    	
	      .fail(function(){
	        console.log("更新失敗");
	      });
    });

    //読了
    $('.finished').click(function(){
          const close = {
           id: $(this).data('id'),
          }
          $(this).parents('tbody').fadeOut(250,function(){
        	$(this).parents('tbody').remove();
          });
	      $.ajax({
	       url: 'http://localhost:8080/MyBooks/members/finished',
	       type: 'GET',
	       data: close
	      })
	      .done(function(res){
	    	location.reload();
	        console.log("削除成功");
	      })                    	
	      .fail(function(){
	        console.log("削除失敗");
	      });
    });
	
	// 現在進行中の本のみ表示する
   	$('#readingBooks').click(function(){
    	const readingPage = document.getElementsByClassName('readingPage');
   		// ブックマークのクラス属性を使って現在進行中か否かを判断する
   		for (let i = 0; i < readingPage.length; i++){
   			if (Number(readingPage[i].value) === 0) {
   				//表示を消す
   				$('.record' + i).css('display','none');
   				$('#readingBooks').css('display','none');
   				$('#allBooks').css('display','inline');
   			}
   		}
   		console.log('現在進行中表示完了');
   	});

    // すべて表示
    $('#allBooks').click(function(){
       $('tr').removeAttr('style');
	$('#allBooks').css('display','none');
      	$('#readingBooks').removeAttr('style');
      	console.log('すべて表示完了');
    });
    
    // 未実装！ブックマークを降順でソート
    $('#sortDesc').click(function(){
		$('#sortDesc').css('display','none');
		$('#sortAsc').css('display','inline');
    });

    // 未実装！ブックマークを昇順でソート
    $('#sortAsc').click(function(){
		$('#sortAsc').css('display','none');
		$('#sortDesc').css('display','inline');
    });
    
 </script>
</body>
</html>