package domain.models

import kotlinx.serialization.Serializable

@Serializable
enum class Language(val code: String) {
    English("en"), Russian("ru");

    companion object {
        val defaultLanguage: Language = entries.first()

        fun instance(name: String): Language? {
            return entries.firstOrNull { it.name == name }
        }

    }
}
