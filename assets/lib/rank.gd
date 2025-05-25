class_name Rank

static func get_ordinal_suffix(number: int) -> String:
    if number % 100 >= 11 and number % 100 <= 13:
        return "th"
    
    match number % 10:
        1: return "st"
        2: return "nd"
        3: return "rd"
        _: return "th"
