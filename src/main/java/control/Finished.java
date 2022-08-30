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
 * Servlet implementation class Finished
 */
@WebServlet("/members/finished")
public class Finished extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
		//DAOの生成
		BookDao bookDao = DaoFactory.createBookDao();
		//finishedメソッドの実行
			bookDao.delete(Integer.parseInt(request.getParameter("id")));
		} catch (Exception e) {
			e.printStackTrace();
		}
		//一覧ページにリダイレクト
		response.sendRedirect(request.getContextPath() + "/members/showBookList");
	}
}
