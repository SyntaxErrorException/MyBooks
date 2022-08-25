package domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Book {
	private Integer userId;
	private String cover;
	private String title;
	private String authors;
	private Integer pageCount;
	private String description;
	private String isbn;
	private Integer bookmark;
}
