ctp = [["Course code", "user email", "Question", "answers"]]
arr.each { |id|
  all_reviews = Review.where(:item_identifier_ids => id).to_a
  code = id

  all_reviews.each { |r|
    email = r.email
    answers = r.answers

    answers.each { |answer|
      obj = [code, email]
      obj << answer.question.question
      obj << answer.answers.join(', ')

      ctp << obj

      code = ""
      email = ""
    }
  }
}
