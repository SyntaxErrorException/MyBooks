package control;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.BookDao;
import dao.DaoFactory;
import domain.Book;

/**
 * Servlet implementation class ShowBookList
 */
@WebServlet("/members/showBookList")
public class ShowBookList extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			// DAOを生成
			BookDao bookDao = DaoFactory.createBookDao();
			// セッションスコープからuserを取得
			// TODO User作成後にコメントアウトを解除
			//User user = (User)request.getSession().getAttribute("user");
			
			// userIdを引数にしてfindByIdメソッドを実行
			// FIXME Userを作成後に修正。それまではベタ打ちIDで対応。

			List<Book> bookList = bookDao.findById(1);// 1 -> user.getId()
			request.setAttribute("bookList", bookList);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		// 一覧にフォワード
		request.getRequestDispatcher("/WEB-INF/view/showBookList.jsp").forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String title = request.getParameter("title");
		String authors = request.getParameter("authors");
		String pageCount = request.getParameter("pageCount");
		String description = request.getParameter("description");
		String cover = request.getParameter("cover");
		String isbn = request.getParameter("isbn");
		String bookmark = request.getParameter("bookmark");

		System.out.println("タイトル：" + title);
		System.out.println("著者：" + authors);
		System.out.println("ページ数：" + pageCount);
		System.out.println("概要：" + description);
		System.out.println("表紙：" + cover);
		System.out.println("ISBN：" + isbn);
		System.out.println("現在のページ：" + bookmark);

		try {
			// DAOの生成
			BookDao bookDao = DaoFactory.createBookDao();
			// DTOの生成
			Book book = new Book();
			// リクエストスコープから取得した値をDTOにセット
			// FIXME Userクラスを作成後、setUserId(1)を修正
			book.setUserId(1);
			book.setTitle(title);
			book.setAuthors(authors);
			book.setPageCount(Integer.parseInt(pageCount));
			book.setDescription(description);
			book.setCover(cover);
			book.setIsbn(isbn);
			book.setBookmark(Integer.parseInt(bookmark));

			bookDao.insert(book);
			
			this.doGet(request, response);
			
		} catch (Exception e) {
			// TODO 自動生成された catch ブロック
			e.printStackTrace();
		}

	}

}
