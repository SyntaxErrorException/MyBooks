package control;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.BookDao;
import dao.DaoFactory;

/**
 * Servlet implementation class Update
 */
@WebServlet("/members/update")
public class Update extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
		// DAOの生成
		BookDao bookDao = DaoFactory.createBookDao();
		// updateメソッドの実行
			bookDao.update(Integer.parseInt(request.getParameter("id")),
					Integer.parseInt(request.getParameter("page")));
		} catch (Exception e) {
			// TODO 自動生成された catch ブロック
			e.printStackTrace();
		}
		// 一覧ページに戻る
		response.sendRedirect(request.getContextPath() + "/members/showBookList");
	}

}
