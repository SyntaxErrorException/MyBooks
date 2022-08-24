package control;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class ShowBookList
 */
@WebServlet("/members/showBookList")
public class ShowBookList extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.getRequestDispatcher("/WEB-INF/view/showBookList.jsp").forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String title = request.getParameter("title");
		String authors = request.getParameter("authors");
		String pageCount = request.getParameter("pageCount");
		String description = request.getParameter("description");
		String cover = request.getParameter("cover");
		String isbn = request.getParameter("isbn");
		String readPage = request.getParameter("readPage");
		
		System.out.println("タイトル：" + title);
		System.out.println("著者：" + authors);
		System.out.println("ページ数：" + pageCount);
		System.out.println("概要：" + description);
		System.out.println("概要の文字数" + description.length());
		System.out.println("表紙：" + cover);
		System.out.println("ISBN：" + isbn);
		System.out.println("現在のページ：" + readPage);
		
		/*
		//DAOの生成
		BookDao bookDao = DaoFactory.createBookDao();
		//DTOの生成
		Book book = new Book();
		//リクエストスコープから取得した値をDTOにセット
		// FIXME ユーザIDを修正
		book.setUserId(1);
		book.setTitle(title);
		book.setAuthors(authors);
		book.setPageCount(Integer.parseInt(pageCount));
		book.setDescription(description);
		book.setCover(cover);
		book.setIsbn(Integer.parseInt(isbn));
		book.setReadPage(Integer.parseInt(readPage));
		try {
			
			bookDao.insert(book);
		} catch (Exception e) {
			// TODO 自動生成された catch ブロック
			e.printStackTrace();
		}
		*/
		
	}

}
